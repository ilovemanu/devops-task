# Python 3.14: current stable line with mature wheel coverage for every
# dependency, supported with security fixes until October 2030.
FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

RUN useradd --create-home --uid 10001 app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY helloapp/ helloapp/

USER 10001

EXPOSE 8080

CMD ["gunicorn", \
     "--bind", "0.0.0.0:8080", \
     "--workers", "2", \
     "helloapp.app:app"]
