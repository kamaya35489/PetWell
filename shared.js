(function(){
  const tc=document.createElement('div');tc.id='toasts';document.body.appendChild(tc);
  window.toast=function(msg,type,dur=3000){
    const el=document.createElement('div');el.className='toast '+(type==='ok'?'ok':type==='err'?'err':'');
    el.textContent=(type==='ok'?'✓ ':type==='err'?'✕ ':'ℹ ')+msg;tc.appendChild(el);
    setTimeout(()=>{el.style.opacity='0';el.style.transition='.3s';},dur-400);
    setTimeout(()=>el.remove(),dur);
  };
  window.openModal=id=>document.getElementById(id)?.classList.remove('hidden');
  window.closeModal=id=>document.getElementById(id)?.classList.add('hidden');
  document.addEventListener('click',e=>{if(e.target.classList.contains('overlay'))e.target.classList.add('hidden');});
  window.fmtDate=function(ts){if(!ts)return'—';const d=ts.toDate?ts.toDate():new Date(ts);return d.toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'});};
  window.confirm2=(msg,cb)=>{if(confirm(msg))cb();};
  // Highlight active admin sidebar link
  const cur=location.pathname.split('/').pop();
  document.querySelectorAll('.as-item[href]').forEach(el=>{if(el.getAttribute('href')===cur)el.classList.add('active');});
})();
