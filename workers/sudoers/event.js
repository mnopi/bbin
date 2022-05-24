/** Service worker https://developers.cloudflare.com/workers/runtime-apis/fetch-event/#parameters **/

addEventListener("fetch", (event) => {
  console.log("Entry");
  event.respondWith(
    handleRequest(event.request).catch(
      (err) => new Response(err.stack, { status: 500 })
    )
  );
});

/**
 * Many more examples available at:
 *   https://developers.cloudflare.com/workers/examples
 * @param {Request} request
 * @returns {Promise<Response>}
 */
async function handleRequest(request) {
  // noinspection JSUnresolvedVariable
  const TOKEN = await kv.get('TOKEN');
  console.log(TOKEN);
  console.log(SECRET)
  return fetch("https://raw.githubusercontent.com/j5pu/bbin/main/bin/bbin");
}
