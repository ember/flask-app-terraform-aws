import requests

from os import getenv
from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from flask_redis import FlaskRedis

app = Flask(__name__)
app.config['REDIS_URL'] = getenv('REDIS_URL', 'redis://localhost:6379/0')

api = Api(app)
redis_store = FlaskRedis(app)

def populate_data():
    if "indices" not in redis_store.keys():
        pipe = redis_store.pipeline()
        obj = {}

        for i in range(1,6):
            r = requests.get('https://api.github.com/search/repositories?q=kubernetes&page={}&per_page=100'.format(i))
            data = r.json()['items']

            for j in range(len(data)):
                obj['id'] = data[j]['id']
                obj['name'] = data[j]['name']
                obj['full_name'] = data[j]['full_name']
                obj['html_url'] = data[j]['html_url']
                obj['language'] = data[j]['language']
                obj['updated_at'] = data[j]['updated_at']
                obj['pushed_at'] = data[j]['pushed_at']
                obj['stargazers_count'] = data[j]['stargazers_count']

                pipe.hmset(data[j]['id'], obj)
                pipe.expire(data[j]['id'], 3600)
                pipe.sadd("indices", data[j]['id'])

        pipe.expire("indices", 3600)
        pipe.execute()

def query_all():
    populate_data()

    obj = []
    for keys in redis_store.smembers("indices"):
        obj.append(redis_store.hgetall(keys))

    return obj

def query_sort(sort_by):
    populate_data()

    obj = []
    for keys in redis_store.sort("indices", by="*->{}".format(sort_by),desc=True):
        obj.append(redis_store.hgetall(keys))

    return obj

def paginate(results_list, page, per_page):
    count = len(results_list)

    start_items = (int(per_page) * int(page)) - int(per_page)
    end_items = start_items + int(per_page)

    obj = {}
    obj['page'] = page
    obj['total_count'] = count
    obj['results'] = results_list[start_items:end_items]

    return obj


class Kubernetes(Resource):
    def get(self):
        q = query_all()

        return jsonify(paginate(q, page=request.args.get('page', 1),
               per_page=request.args.get('per_page', 500)))


class KubernetesPop(Resource):
    def get(self):
        q = query_all()
        return jsonify(paginate(query_sort("stargazers_count"),
               page=request.args.get('page', 1),
               per_page=request.args.get('per_page', 10)))

class KubernetesAct(Resource):
    def get(self):
        q = query_all()
        n = sorted(q, key=lambda k: k['updated_at'])

        return jsonify(paginate(n,
               page=request.args.get('page', 1),
               per_page=request.args.get('per_page', 10)))


api.add_resource(Kubernetes, '/api/kubernetes')
api.add_resource(KubernetesPop, '/api/popularity/kubernetes')
api.add_resource(KubernetesAct, '/api/activity/kubernetes')

if __name__ == '__main__':
    populate_data()
    app.run(host='0.0.0.0',port=5000)
