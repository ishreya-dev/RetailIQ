FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    RetainIQ_DATA_DIR=/app/data/runtime

WORKDIR /app

COPY pyproject.toml README.md ./
COPY RetainIQ ./RetainIQ
RUN pip install --no-cache-dir .

COPY index.html app.js styles.css ./

EXPOSE 8000

CMD ["sh", "-c", "python -m RetainIQ.training && uvicorn RetainIQ.main:app --host 0.0.0.0 --port 8000"]
