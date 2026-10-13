FROM python:3.13-alpine
LABEL org.opencontainers.image.source="https://github.com/YashSensei/devops-assignment" \
      org.opencontainers.image.title="KitLedger backend" \
      org.opencontainers.image.description="Equipment lending API with availability, returns and maintenance rules" \
      org.opencontainers.image.licenses="MIT"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN apk upgrade --no-cache && pip install --no-cache-dir -r requirements.txt && pip uninstall -y pip setuptools && addgroup -g 10001 appuser && adduser -D -u 10001 -G appuser appuser
COPY --chown=10001:10001 app ./app
COPY --chown=10001:10001 alembic ./alembic
COPY --chown=10001:10001 alembic.ini .
USER 10001:10001
EXPOSE 8000
CMD ["sh", "-c", "python -m app.migrate && uvicorn app.main:create_app --factory --host 0.0.0.0 --port 8000"]
