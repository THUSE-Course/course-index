FROM docker.net9.org/library/python:3.12 AS build

WORKDIR /app

COPY requirements.txt .

RUN pip install -i https://pypi-cache-sepi.app.spring25a.secoder.net/simple --no-cache-dir -r requirements.txt

COPY . .

RUN mkdocs build

FROM docker.net9.org/library/nginx:alpine AS runtime

COPY --from=build /app/site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
