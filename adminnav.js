(function(){
  const links=[
    {href:'admindash.html',icon:'⊞',label:'Dashboard'},
    {href:'adminpets.html',icon:'🐾',label:'Pet Profiles'},
    {href:'adminbookings.html',icon:'📅',label:'Bookings'},
    {href:'adminstore.html',icon:'🛍',label:'Store'},
    {href:'admindelivery.html',icon:'🚚',label:'Delivery'},
    {href:'admindrivers.html',icon:'🧑‍✈️',label:'Drivers'},
    {href:'adminfeedback.html',icon:'💬',label:'Feedback'},
    {href:'admincctv.html',icon:'📹',label:'CCTV'},
  ];
  const active=window.ACTIVE||location.pathname.split('/').pop();
  const sb=document.querySelector('.admin-sidebar');
  if(sb)sb.innerHTML=`<div class="as-logo"><span style="font-size:1.4rem">🐾</span><span class="as-logo-text">PetWell Admin</span></div><nav class="as-nav">${links.map(l=>`<a href="${l.href}" class="as-item${l.href===active?' active':''}"><span class="as-icon">${l.icon}</span>${l.label}</a>`).join('')}</nav><div class="as-footer"><button class="as-logout" onclick="doLogout()">↪ Sign Out</button></div>`;
  // Mobile bottom nav
  const mn=document.createElement('nav');mn.className='bottom-nav';
  mn.innerHTML=links.slice(0,6).map(l=>`<a class="nav-tab${l.href===active?' active':''}" href="${l.href}"><span class="nt-icon">${l.icon}</span><span class="nt-label">${l.label.split(' ')[0]}</span><div class="nav-underline"></div></a>`).join('');
  document.body.appendChild(mn);
  function tog(){mn.style.display=window.innerWidth<=700?'flex':'none';}
  tog();window.addEventListener('resize',tog);
})();
