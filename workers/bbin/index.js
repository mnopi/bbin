/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npx wrangler dev src/index.js` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npx wrangler publish src/index.js --name my-worker` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */
export default {
  /**
   * Many more examples available at:
   *   https://developers.cloudflare.com/workers/examples
   * @param {Request} request
   * @param {Object} env
   * @param {Object} context
   * @returns {Promise<Response>}
   */
  async fetch(request, env, context) {
    return new Response(await fetch("https://raw.githubusercontent.com/j5pu/bbin/main/bin/bbin")
      .then(response => response.text()));
  },
};
