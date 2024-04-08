import { withRouterLinks } from 'https://unpkg.com/slick-router@2.5.0/middlewares/router-links.js'

customElements.define('application-view',
  class ApplicationView extends withRouterLinks(HTMLElement) {
    constructor() {
      super()
      this.addEventListener('change', e => {
        if (e.target.matches('#animation-type')) {
          const animation = e.target.value
          if (animation) {
            this.outlet.setAttribute('animation', e.target.value)
          } else {
            this.outlet.removeAttribute('animation')
          }
        }
      })
      this.addEventListener('load', e => {
        const data = e.detail;
        notify(JSON.stringify(data.items[0]));
      }
      )
      // Custom function to emit toast notifications
      function notify(message, variant = 'primary', icon = 'info-circle', duration = 3000) {
        const alert = Object.assign(document.createElement('sl-alert'), {
          variant,
          closable: true,
          duration: duration,
          innerHTML: `
        <sl-icon name="${icon}" slot="icon"></sl-icon>
        ${message}
      `
        });

        document.body.append(alert);
        return alert.toast();
      }
      // Always escape HTML for text arguments!
      function escapeHtml(html) {
        const div = document.createElement('div');
        div.textContent = html;
        return div.innerHTML;
      }
      this.addEventListener('click', e => {
        if (e.target.matches('#more-toast')) {
          const alert = this.querySelector('#toaster')
          notify(`This is custom toast `);
        }
      })
    }

    connectedCallback() {
      super.connectedCallback()
      this.innerHTML = `
      <div class='App'>
        <div class='App-header'>
          <h1>Application</h1>
          <ul class='Nav' routerlinks>
            <li class='Nav-item'><a route="home" >Home</a></li>
            <li class='Nav-item'><a route="tweets" >Tweets</a></li>
            <li class='Nav-item'><a route="messages">Messages</a></li>
            <li class='Nav-item'><a route="profile.index" param-user="scrobblemuch">Profile</a></li>
            <li class='Nav-item'><a route="settings" >Settings</a></li>
          </ul>
         

        </div>
        <router-outlet animation="fade"></router-outlet>
        
        <div class="App-footer">
          <div>
            Animation
            <select id="animation-type">
              <option value="">None</option>
              <option value="fade" selected>Fade</option>
              <option value="slide-fade">Slide Fade</option>
              <option value="bounce">Bounce</option>
            </select>
            <button id="more-toast">toast</button>
                    
          </div>        
        </div> 
        
      </div>
    `
      this.outlet = this.querySelector('router-outlet')
    }
  }
)
customElements.define('home-view',
  class HomeView extends withRouterLinks(HTMLElement) {
    connectedCallback() {
      this.getModel();
    }
    getModel() {
      return new Promise((res, rej) => {
        fetch('/pdf/api/sources')
          .then(data => data.json())
          .then((json) => {
            this.renderPosts(json);
            res();
          })
          .catch((error) => rej(error));
      })
    }
    renderPosts(data) {
      const count = data.count
      const shadowRoot = this.attachShadow({ mode: "open" });
      const div = document.createElement("div", { class: "cards" });
      shadowRoot.appendChild(div);
      data.items.forEach(item => {
        div.appendChild(Object.assign(
          document.createElement('sl-card'), { class: "card", textContent: item.slug })
        )
      })
    }
  }
)

customElements.define('tweet-view',
  class TweetView extends withRouterLinks(HTMLElement) {
    connectedCallback() {
      super.connectedCallback()
      this.innerHTML = `
      <div class='Home' routerlinks>
        <h2>Tweets</h2>
        <div class='Tweet'>
          <div class='Tweet-author'>
          <a route="profile.index" param-user="dan_abramov">Dan Abramov ‏@dan_abramov</a>
          </div>
          <div class='Tweet-time'>12m12 minutes ago</div>
          <div class='Tweet-content'>Another use case for \`this.context\` I think might be valid: forms. They're too painful right now.</div>
        </div>
        <div class='Tweet'>
          <div class='Tweet-author'>
            <a route="profile.index" param-user="afanasjevas">Eduardas Afanasjevas ‏@afanasjevas</a>
          </div>
          <div class='Tweet-time'>12m12 minutes ago</div>
          <div class='Tweet-content'>I just published “What will Datasmoothie bring to the analytics startup landscape?” https://medium.com/@afanasjevas/what-will-datasmoothie-bring-to-the-analytics-startup-landscape-f7dab70d75c3?source=tw-81c4e81fe6f8-1427630532296</div>
        </div>
        <div class='Tweet'>
          <div class='Tweet-author'>
            <a route="profile.index" param-user="LNUGorg">LNUG ‏@LNUGorg</a>
          </div>
          <div class='Tweet-time'>52m52 minutes ago</div>
          <div class='Tweet-content'> new talks uploaded on our YouTube page - check them out http://bit.ly/1yoXSAO</div>
        </div>
      </div>
    `
    }
  }
)
customElements.define('messages-view',
  class MessagesView extends HTMLElement {
    connectedCallback() {
      this.innerHTML = `
      <div class='Messages'>
        <h2>Messages</h2>
        <p>You have no direct messages</p>
        <sl-tree>
  <sl-tree-item lazy>Available Trees</sl-tree-item>
</sl-tree>

<script type="module">
  const lazyItem = document.querySelector('sl-tree-item[lazy]');

  lazyItem.addEventListener('sl-lazy-load', () => {
   alert("heelo");
  });
</script>

      </div>
    `
    }
  }
)
customElements.define('settings-view',
  class SettingsView extends HTMLElement {
    connectedCallback() {
      this.innerHTML = `
      <div class='Messages'>
        <a href="/pdf/api/sources" target="_blank">DATA</a>
        <h2>Settings</h2>
        <div>
            Animation
            <select id="animation-type2">
              <option value="">None</option>
              <option value="fade" selected>Fade</option>
              <option value="slide-fade">Slide Fade</option>
              <option value="bounce">Bounce</option>
            </select>            
          </div> 
          <sl-alert variant="neutral" duration="3000" closable >
          <sl-icon slot="icon" name="gear"></sl-icon>
          <strong>Your settings have been updated</strong><br />
          Settings will take effect on next login.
        </sl-alert>
        <fetch-json src='/pdf/api/sources'/>     
      </div>
    `
    }
  }
)
customElements.define('profile-view',
  class ProfileView extends HTMLElement {
    static get outlet() {
      return '.Container'
    }

    connectedCallback() {
      this.innerHTML = `
      <div class='Profile'>
        <div class='Container'></div>
      </div>
    `
    }
  }
)

customElements.define('profile-index-view',
  class ProfileIndexView extends HTMLElement {

    connectedCallback() {

      this.innerHTML = `
      <div class='ProfileIndex'>
        <h2>${this.$route.params.user} profile</h2>
      </div>
    `
    }
  }
)
customElements.define('cards-panel',
  class CardPanel extends HTMLElement {
    constructor(){
      super();
      const template = document.createElement('template');
      template.id = 'pool-calculator-template';
      template.innerHTML = `     
      <style>
        
      </style>
      
      <div class="input-section">
      
        <!-- ... -->
      
      </div>
      `;
    }
    connectedCallback() {
      this.innerHTML = `
      <div class='ProfileIndex'>
        <h2>${this.$route.params.user} profile</h2>
      </div>
    `
    }
  }
)
customElements.define('fetch-json',
  class FetchJson extends HTMLElement {
    static observedAttributes = ["src", "size"];

    connectedCallback() {
      this.getModel();
    }
    getModel() {
      const src = this.getAttribute('src')
        + "?" + new URLSearchParams({ foo: 'value', bar: 2, });
      return new Promise((res, rej) => {
        fetch(src)
          .then(data => data.json())
          .then((json) => {
            this.data=data;
            this.renderPosts(json);
            res();
          })
          .catch((error) => rej(error));
      })
    }
    renderPosts(data) {
      this.innerHTML = `<span>${this.getAttribute('src')} : ${data.count}</span>`;
      
      this.dispatchEvent(new CustomEvent("load", {
        detail: data,
        composed: true,
        bubbles: true
      }));
    }
  }
)
