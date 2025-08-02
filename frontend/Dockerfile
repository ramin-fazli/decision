# Frontend Dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN \
  if [ -f package-lock.json ]; then npm ci --only=production; \
  else echo "package-lock.json not found." && npm install --only=production; \
  fi

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Debug: Check what was copied
RUN echo "Checking copied files..." && \
    ls -la && \
    echo "Checking public folder..." && \
    ls -la public/ || echo "No public folder found after copy"

# Install all dependencies for building
RUN npm install

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the application with better error handling and debugging
RUN npm run build 2>&1 | tee build.log && \
    echo "Build completed. Checking for standalone output..." && \
    ls -la .next/ && \
    echo "Checking public folder..." && \
    ls -la public/ || echo "No public folder found" && \
    if [ ! -d ".next/standalone" ]; then \
      echo "ERROR: Standalone output not found." && \
      echo "Build log:" && \
      cat build.log && \
      exit 1; \
    else \
      echo "SUCCESS: Standalone output found." && \
      ls -la .next/standalone/; \
    fi

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Create necessary directories
RUN mkdir -p ./public ./.next/static

# Copy standalone server files first
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./

# Copy static assets
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy public folder (make it optional to avoid build failures)
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
