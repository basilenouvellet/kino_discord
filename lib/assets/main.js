export function init(ctx, payload) {
  ctx.importCSS("main.css");
  ctx.importCSS(
    "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
  );
  ctx.importCSS(
    "https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.min.css"
  );
  ctx.importJS("https://unpkg.com/alpinejs@3.10.5/dist/cdn.min.js");

  ctx.root.innerHTML = `
    <div class="app" x-data="{helpBoxOpen: false}">
      <form>
        <div class="container">
          <div class="row header">
            <div class="icon-logo">
              <img src="slack_logo.svg">
            </div>
            <div class="inline-field">
              <label class="inline-input-label">Post to</label>
              <input class="input input--xs input-text" id="channel" placeholder="#channel-name">
            </div>
            <div class="inline-field">
              <label class="inline-input-label">Token</label>
              <input class="input input--xs input-text" id="token" placeholder="xoxb-something"readonly>
            </div>
            <div class="grow"></div>
            <button type="button" class="icon-button" @click="helpBoxOpen = !helpBoxOpen">
              <i class="ri ri-questionnaire-line" aria-hidden="true"></i>
            </button>
          </div>
          <div class="help-box" x-cloak x-show="helpBoxOpen">
            <div class="section">
              <p>
                This Smart cell sends a message to a Slack channel. In order to use it, you need to
                <a href="https://api.slack.com/tutorials/tracks/getting-a-token" target="_blank">create a Slack app and get your app's token</a>.
              </p>
            </div>
          </div>
          <div class="row">
            <div class="field grow">
              <label class="input-label">Message</label>
              <textarea id="message" rows="10" class="input input--text-area" placeholder="Insert your Slack message here..."></textarea>
            </div>
          </div>
        </div>
      </form>
    </div>
  `;

  const tokenEl = document.getElementById("token");
  tokenEl.value = payload.fields.token_secret_name;

  const channelEl = document.getElementById("channel");
  channelEl.value = payload.fields.channel;

  const messageEl = document.getElementById("message");
  messageEl.value = payload.fields.message;

  channelEl.addEventListener("change", (event) => {
    ctx.pushEvent("update_channel", event.target.value)
  });

  messageEl.addEventListener("change", (event) => {
    ctx.pushEvent("update_message", event.target.value)
  });

  tokenEl.addEventListener("click", (event) => {
    ctx.selectSecret((secret_name) => {
      ctx.pushEvent("update_token_secret_name", secret_name);
    }, "SLACK_TOKEN")
  });

  ctx.handleEvent("update_token_secret_name", (token_secret_name) => {
    tokenEl.value = token_secret_name;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
