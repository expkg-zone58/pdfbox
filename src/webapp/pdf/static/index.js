import { Router } from 'https://unpkg.com/slick-router@2.5.0/slick-router.js?module'
import { wc } from 'https://unpkg.com/slick-router@2.5.0/middlewares/wc.js'
import { events } from 'https://unpkg.com/slick-router@2.5.0/middlewares/events.js'
import { routerLinks } from 'https://unpkg.com/slick-router@2.5.0/middlewares/router-links.js'
import { AnimatedOutlet } from 'https://unpkg.com/slick-router@2.5.0/components/animated-outlet.js'

import './components.js'

customElements.define('router-outlet', AnimatedOutlet)

// create the router
const router = new Router({
  pushState: true,
 
  log: true
})

// provide your route map
// in this particular case we configure components by its tag name

router.map(route => {
  route('application', { path: '/pdf/', 
                         component: 'application-view' }, () => {
    route('home', { path: '', component: 'home-view' })                      
    route('tweets', { component: 'tweet-view' })
    route('messages', { component: 'messages-view' })
    route('status', { path: ':user/status/:id' })
    route('profile', { path: 'profile/:user', component: 'profile-view' }, () => {
      route('profile.index', { path: '', component: 'profile-index-view' })
      route('profile.lists')
      route('profile.edit')
    })
    route('settings',{path: 'settings',component:'settings-view'})
  })
})

// install middleware that will handle transitions
router.use(wc)
router.use(routerLinks)
router.use(events)

// start listening to browser's location bar changes
router.listen()
