
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --only=production



FROM node:20-alpine

WORKDIR /app



ENV NODE_ENV=production

ENV PORT=3000

ENV APP_NAME="defaultApp"



COPY --from=deps /app/node_modules ./node_modules

COPY index.js ./



EXPOSE 3000



HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \

  CMD wget -qO- http://127.0.0.1:${PORT}/ || exit 1



RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser



CMD ["node", "index.js"]

