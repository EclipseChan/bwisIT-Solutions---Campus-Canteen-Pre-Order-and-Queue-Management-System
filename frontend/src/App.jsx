import { useState, useEffect, useCallback } from 'react'

const API = 'http://localhost:8080'
const money = n => '₱' + Number(n).toFixed(2)
let token = sessionStorage.getItem('token')

async function api(path, { method = 'GET', body } = {}) {
  const res = await fetch(API + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  })
  const data = await res.json().catch(() => null)
  if (!res.ok) {
    const f = data?.fields ? ': ' + Object.entries(data.fields).map(([k, v]) => `${k} ${v}`).join(', ') : ''
    throw new Error((data?.error || 'Request failed (' + res.status + ')') + f)
  }
  return data
}

function useGet(path) {
  const [data, setData] = useState(null)
  const [err, setErr] = useState('')
  const load = useCallback(() => {
    if (!path) return setData(null)
    api(path).then(d => { setData(d); setErr('') }).catch(e => setErr(e.message))
  }, [path])
  useEffect(load, [load])
  return [data, load, err]
}

const Msg = ({ m }) => m ? <p className={m.ok ? 'ok' : 'err'}>{m.text}</p> : null

function Auth({ onAuth }) {
  const [mode, setMode] = useState('login')
  const [f, setF] = useState({})
  const [msg, setMsg] = useState(null)
  const set = k => e => setF({ ...f, [k]: e.target.value })
  const submit = async e => {
    e.preventDefault()
    const path = mode === 'login' ? '/api/auth/login' : '/api/auth/register/' + mode
    try { onAuth(await api(path, { method: 'POST', body: f })) }
    catch (x) { setMsg({ text: x.message }) }
  }
  return (
    <main>
      <nav>
        {[['login', 'Log in'], ['student', 'Register as student'], ['vendor', 'Register a stall']].map(([k, l]) =>
          <button key={k} className={mode === k ? 'on' : 'alt'} onClick={() => { setMode(k); setMsg(null) }}>{l}</button>)}
      </nav>
      <form className="card" onSubmit={submit}>
        {mode === 'student' && <input placeholder="Full name" onChange={set('fullName')} required />}
        {mode === 'vendor' && <>
          <input placeholder="Stall name" onChange={set('vendorName')} required />
          <input placeholder="Contact number (optional)" onChange={set('contactNumber')} />
        </>}
        <input type="email" placeholder="Email" onChange={set('email')} required />
        <input type="password" placeholder="Password (8+ characters)" onChange={set('password')} required />
        <button>{mode === 'login' ? 'Log in' : 'Register'}</button>
        <Msg m={msg} />
      </form>
    </main>
  )
}

function Student() {
  const [tab, setTab] = useState('order')
  const [stalls] = useGet('/api/vendors')
  const [vendor, setVendor] = useState(null)
  const [menu] = useGet(vendor ? `/api/vendors/${vendor.id}/menu` : null)
  const [cart, setCart] = useState({})
  const [pickup, setPickup] = useState('')
  const [orders, reloadOrders] = useGet('/api/orders')
  const [notes, reloadNotes] = useGet('/api/notifications')
  const [msg, setMsg] = useState(null)

  const place = async () => {
    const items = Object.entries(cart).filter(([, q]) => q > 0).map(([itemId, quantity]) => ({ itemId: +itemId, quantity }))
    try {
      const o = await api('/api/orders', { method: 'POST', body: { vendorId: vendor.id, pickupTime: pickup, items } })
      setMsg({ ok: true, text: `Order placed. Your queue number is ${o.queueNumber}.` })
      setCart({}); reloadOrders(); reloadNotes()
    } catch (x) { setMsg({ text: x.message }) }
  }
  const cancel = async id => {
    try { await api(`/api/orders/${id}/cancel`, { method: 'POST' }); reloadOrders(); reloadNotes() }
    catch (x) { setMsg({ text: x.message }) }
  }
  const read = async id => { await api(`/api/notifications/${id}/read`, { method: 'PATCH' }); reloadNotes() }
  const unread = (notes || []).filter(n => !n.read).length

  return (<main>
    <nav>
      {[['order', 'Order food'], ['orders', 'My orders'], ['notes', `Notifications (${unread})`]].map(([k, l]) =>
        <button key={k} className={tab === k ? 'on' : 'alt'} onClick={() => { setTab(k); setMsg(null) }}>{l}</button>)}
    </nav>
    <Msg m={msg} />
    {tab === 'order' && <>
      <section><h3>Stalls</h3>
        {(stalls || []).map(s => <div className="row" key={s.id}>
          <span>{s.vendorName} <span className="muted">{s.contactNumber}</span></span>
          <button className={vendor?.id === s.id ? 'on' : 'alt'} onClick={() => { setVendor(s); setCart({}) }}>View menu</button>
        </div>)}
      </section>
      {vendor && <section><h3>{vendor.vendorName} menu</h3>
        {(menu || []).filter(m => m.available).map(m => <div className="row" key={m.id}>
          <span>{m.itemName} <span className="muted">{money(m.price)}</span></span>
          <input type="number" min="0" max="20" style={{ width: 60 }} value={cart[m.id] || 0}
            onChange={e => setCart({ ...cart, [m.id]: +e.target.value })} />
        </div>)}
        <p>Pickup time: <input type="time" value={pickup} onChange={e => setPickup(e.target.value)} /></p>
        <button onClick={place} disabled={!pickup || !Object.values(cart).some(q => q > 0)}>Place order</button>
      </section>}
    </>}
    {tab === 'orders' && <section><h3>My orders</h3>
      {(orders || []).map(o => <div className="row" key={o.orderId}>
        <span>#{o.orderId} {o.vendorName}, pickup {o.pickupTime?.slice(0, 5)}, {money(o.total)}<br />
          <span className="muted">{o.items.map(i => `${i.quantity}x ${i.itemName}`).join(', ')} | queue {o.queueNumber}, {o.peopleAhead} ahead</span></span>
        <span><span className="tag">{o.status}</span> {o.status === 'pending' && <button className="danger" onClick={() => cancel(o.orderId)}>Cancel</button>}</span>
      </div>)}
      {orders?.length === 0 && <p className="muted">No orders yet.</p>}
    </section>}
    {tab === 'notes' && <section><h3>Notifications</h3>
      {(notes || []).map(n => <div className="row" key={n.id}>
        <span style={{ fontWeight: n.read ? 400 : 700 }}>{n.message} <span className="muted">order #{n.orderId}</span></span>
        {!n.read && <button className="alt" onClick={() => read(n.id)}>Mark read</button>}
      </div>)}
      {notes?.length === 0 && <p className="muted">Nothing yet.</p>}
    </section>}
  </main>)
}

function Report({ path, showVendors }) {
  const [r] = useGet(path)
  if (!r) return <p className="muted">Loading report...</p>
  return (<section><h3>Sales</h3>
    <p>Orders: {r.totalOrders} (completed {r.completedOrders}, cancelled {r.cancelledOrders}) | Revenue: {money(r.revenue)} | Average: {money(r.averageOrderValue)}</p>
    <h3>Top items</h3>
    {r.topItems.map(t => <div className="row" key={t.itemName}><span>{t.itemName}</span><span>{t.quantitySold} sold, {money(t.revenue)}</span></div>)}
    {showVendors && <><h3>By stall</h3>
      {r.byVendor.map(v => <div className="row" key={v.vendorId}><span>{v.vendorName}</span><span>{v.orders} orders, {money(v.revenue)}</span></div>)}</>}
  </section>)
}

const NEXT = { pending: 'preparing', preparing: 'ready', ready: 'completed' }

function Vendor() {
  const [tab, setTab] = useState('orders')
  const [orders, reloadOrders] = useGet('/api/vendor/orders')
  const [menu, reloadMenu] = useGet('/api/vendor/menu')
  const [item, setItem] = useState({ itemName: '', price: '' })
  const [msg, setMsg] = useState(null)
  const run = async (fn, after) => {
    try { const r = await fn(); if (r?.message) setMsg({ ok: true, text: r.message }); after() } catch (x) { setMsg({ text: x.message }) }
  }
  const status = (id, s) => run(() => api(`/api/vendor/orders/${id}/status`, { method: 'PATCH', body: { status: s } }), reloadOrders)
  const add = e => {
    e.preventDefault()
    run(() => api('/api/vendor/menu', { method: 'POST', body: { itemName: item.itemName, price: +item.price } }), () => { setItem({ itemName: '', price: '' }); reloadMenu() })
  }
  return (<main>
    <nav>{[['orders', 'Orders'], ['menu', 'Menu'], ['sales', 'Sales']].map(([k, l]) =>
      <button key={k} className={tab === k ? 'on' : 'alt'} onClick={() => { setTab(k); setMsg(null) }}>{l}</button>)}</nav>
    <Msg m={msg} />
    {tab === 'orders' && <section><h3>Incoming orders</h3>
      {(orders || []).map(o => <div className="row" key={o.orderId}>
        <span>#{o.orderId} queue {o.queueNumber}, {o.studentName}, pickup {o.pickupTime?.slice(0, 5)}<br />
          <span className="muted">{o.items.map(i => `${i.quantity}x ${i.itemName}`).join(', ')} | {money(o.total)}</span></span>
        <span><span className="tag">{o.status}</span>{' '}
          {NEXT[o.status] && <button onClick={() => status(o.orderId, NEXT[o.status])}>Mark {NEXT[o.status]}</button>}{' '}
          <button className="danger" onClick={() => status(o.orderId, 'cancelled')}>Cancel</button></span>
      </div>)}
      {orders?.length === 0 && <p className="muted">No active orders.</p>}
    </section>}
    {tab === 'menu' && <>
      <form className="card" onSubmit={add}><h3>Add item</h3>
        <input placeholder="Item name" value={item.itemName} onChange={e => setItem({ ...item, itemName: e.target.value })} required />
        <input type="number" step="0.01" min="0" placeholder="Price" value={item.price} onChange={e => setItem({ ...item, price: e.target.value })} required />
        <button>Add</button></form>
      <section><h3>My menu</h3>
        {(menu || []).map(m => <div className="row" key={m.id}>
          <span>{m.itemName} <span className="muted">{money(m.price)}</span></span>
          <span><button className="alt" onClick={() => run(() => api(`/api/vendor/menu/${m.id}/availability`, { method: 'PATCH', body: { available: !m.available } }), reloadMenu)}>
            {m.available ? 'Available (hide)' : 'Hidden (show)'}</button>{' '}
            <button className="danger" onClick={() => run(() => api(`/api/vendor/menu/${m.id}`, { method: 'DELETE' }), reloadMenu)}>Delete</button></span>
        </div>)}
      </section></>}
    {tab === 'sales' && <Report path="/api/vendor/reports/sales" />}
  </main>)
}

function Admin() {
  const [tab, setTab] = useState('stalls')
  const [vendors, reload] = useGet('/api/admin/vendors')
  const [msg, setMsg] = useState(null)
  const toggle = async v => {
    try { await api(`/api/admin/vendors/${v.id}/active`, { method: 'PATCH', body: { active: !v.active } }); reload() }
    catch (x) { setMsg({ text: x.message }) }
  }
  return (<main>
    <nav>{[['stalls', 'Stalls'], ['sales', 'Sales']].map(([k, l]) =>
      <button key={k} className={tab === k ? 'on' : 'alt'} onClick={() => setTab(k)}>{l}</button>)}</nav>
    <Msg m={msg} />
    {tab === 'stalls' && <section><h3>All stalls</h3>
      {(vendors || []).map(v => <div className="row" key={v.id}>
        <span>{v.vendorName} <span className="muted">{v.contactNumber}</span></span>
        <button className={v.active ? 'alt' : ''} onClick={() => toggle(v)}>{v.active ? 'Active (switch off)' : 'Off (switch on)'}</button>
      </div>)}
    </section>}
    {tab === 'sales' && <Report path="/api/admin/reports/sales" showVendors />}
  </main>)
}

export default function App() {
  const [user, setUser] = useState(() => JSON.parse(sessionStorage.getItem('user') || 'null'))
  const onAuth = u => { token = u.token; sessionStorage.setItem('token', u.token); sessionStorage.setItem('user', JSON.stringify(u)); setUser(u) }
  const logout = () => { token = null; sessionStorage.clear(); setUser(null) }
  const View = { STUDENT: Student, VENDOR: Vendor, ADMIN: Admin }[user?.role]
  return (<>
    <header>
      <strong>Campus Canteen</strong>
      {user && <span>{user.name} ({user.role.toLowerCase()}) <button className="alt" onClick={logout}>Log out</button></span>}
    </header>
    {View ? <View /> : <Auth onAuth={onAuth} />}
  </>)
}
