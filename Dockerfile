FROM python:3.12 AS build

WORKDIR /app

COPY requirements.txt .

RUN pip install --index-url https://pypi.t.secoder.net/+simple --no-cache-dir -r requirements.txt

COPY . .

RUN mkdocs build

FROM nginx:alpine AS runtime

COPY --from=build /app/site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
