/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['ipfs.io', 'gateway.pinata.cloud'],
    unoptimized: true, // required for Netlify static export compatibility
  },
};

module.exports = nextConfig;
