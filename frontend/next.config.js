/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: [
      'ipfs.io',
      'cloudflare-ipfs.com',
      'gateway.pinata.cloud',
      'w3s.link',
    ],
    unoptimized: true,
  },
};

module.exports = nextConfig;
