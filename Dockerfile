# Stage 1: Build the Quarto site
FROM ubuntu:24.04 AS builder

ARG QUARTO_VERSION=1.9.37

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto CLI
RUN curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

WORKDIR /build

# Install Python dependencies
COPY pyproject.toml uv.lock* ./
RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install jupyter nbconvert

ENV PATH="/venv/bin:$PATH"

# Copy project files and render
COPY . .
RUN quarto render --no-cache

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /build/_site /usr/share/nginx/html

# Custom nginx config for SPA-style routing (optional but useful)
RUN printf 'server {\n\
    listen 80;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ $uri.html =404;\n\
    }\n\
    gzip on;\n\
    gzip_types text/plain text/css application/javascript text/html;\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
