import React, {useEffect, useState} from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';

const emptyEquipment = {asset_tag:'', name:'', category:'', condition:'ready', notes:''};
const dateInWeek = () => {const d = new Date(); d.setDate(d.getDate()+7); return localDate(d);};
function localDate(d) {return [d.getFullYear(), String(d.getMonth()+1).padStart(2,'0'), String(d.getDate()).padStart(2,'0')].join('-');}
async function request(path, options = {}) {
  const response = await fetch(path, {...options, headers:{'Content-Type':'application/json'}});
  if (!response.ok) {
    let data; try {data = await response.json();} catch {throw new Error('Server request failed. Please retry.');}
    throw new Error(Array.isArray(data.detail) ? data.detail.map(e => e.loc.at(-1)+': '+e.msg).join('; ') : data.detail || 'Request failed');
  }
  return response.status === 204 ? null : response.json();
}
function App() {
  const [tab,setTab]=useState('equipment'), [equipment,setEquipment]=useState([]), [loans,setLoans]=useState([]);
  const [summary,setSummary]=useState(null), [loading,setLoading]=useState(true), [error,setError]=useState('');
  const [query,setQuery]=useState(''), [filter,setFilter]=useState('all'), [modal,setModal]=useState(null);
  const [form,setForm]=useState({}), [saving,setSaving]=useState(false), [formError,setFormError]=useState(''), [notice,setNotice]=useState('');
  async function refresh() {
    setError('');
    try {
      const [items,history,counts]=await Promise.all([request('/api/equipment'),request('/api/loans'),request('/api/summary')]);
      setEquipment(items);setLoans(history);setSummary(counts);
    } catch(e) {setError(e.message);} finally {setLoading(false);}
  }
  useEffect(()=>{refresh();},[]);
  useEffect(()=>{
    if (!modal) return;
    const handler=(event)=>{if(event.key==='Escape' && !saving)setModal(null);};
    document.addEventListener('keydown',handler);return ()=>document.removeEventListener('keydown',handler);
  },[modal,saving]);
  function open(kind,item) {
    setModal({kind,item});setFormError('');
    if(kind==='equipment')setForm(item ? {asset_tag:item.asset_tag,name:item.name,category:item.category,condition:item.condition,notes:item.notes} : {...emptyEquipment});
    if(kind==='loan')setForm({equipment_id:item.id,borrower:'',purpose:'',due_on:dateInWeek()});
    if(kind==='return')setForm({condition:'ready'});
  }
  function change(e) {setForm({...form,[e.target.name]:e.target.value});}
  async function save(e) {
    e.preventDefault();setSaving(true);setFormError('');
    try {
      let path, method='POST';
      if(modal.kind==='equipment'){path='/api/equipment'+(modal.item ? '/'+modal.item.id : '');method=modal.item?'PUT':'POST';}
      if(modal.kind==='loan')path='/api/loans';
      if(modal.kind==='return')path='/api/loans/'+modal.item.id+'/return';
      if(modal.kind==='delete'){path='/api/equipment/'+modal.item.id;method='DELETE';}
      await request(path,{method,body:method==='DELETE'?undefined:JSON.stringify(form)});
      setNotice(modal.kind==='loan'?'Loan recorded. Equipment is now checked out.':modal.kind==='return'?'Return recorded in loan history.':modal.kind==='delete'?'Unused equipment deleted.':'Equipment saved.');
      setModal(null);await refresh();
    } catch(e) {setFormError(e.message);} finally {setSaving(false);}
  }
  const visibleEquipment=equipment.filter(item=>(item.name+' '+item.asset_tag+' '+item.category).toLowerCase().includes(query.toLowerCase()) && (filter==='all'||(filter==='available'?item.available:filter==='on-loan'?!item.available&&item.condition==='ready':item.condition===filter)));
  const visibleLoans=loans.filter(item=>(item.borrower+' '+item.asset_tag+' '+item.equipment_name).toLowerCase().includes(query.toLowerCase())&&(filter==='all'||item.status===filter));
  const counts=[['IN THE LIBRARY',summary?.total,'Unique equipment'],['READY TO BORROW',summary?.available,'Checked in & ready'],['OUT ON LOAN',summary?.on_loan,'Currently with borrowers'],['NEEDS ATTENTION',summary ? summary.overdue+summary.maintenance : null,'Overdue + maintenance']];
  return <div className="app">
    <header className="topbar"><a className="brand" href="/"><span className="mark">K<span>↗</span></span><span>KitLedger<small>THE EQUIPMENT LIBRARY</small></span></a><span className="workspace">YA<span>Yash's workspace<small>Equipment operations</small></span></span></header>
    <main>
      <div className="intro"><div><p className="eyebrow">KEEP GOOD THINGS IN CIRCULATION</p><h1>A place for every kit.<br/><span>A record for every loan.</span></h1><p className="subheading">Know what’s ready, who has it, and when it’s coming back.</p></div><button className="primary" onClick={()=>open('equipment')}>＋ Add equipment</button></div>
      <section className="stats" aria-label="Inventory summary">{counts.map(([label,count,desc],i)=><article key={label}><div className="stat-label"><span>{label}</span><span className="stat-symbol">{['▤','↗','↔','!'][i]}</span></div><strong>{count??'—'}</strong><small>{desc}</small></article>)}</section>
      {notice&&<div role="status" className="notice">{notice}<button onClick={()=>setNotice('')} aria-label="Dismiss notification">×</button></div>}
      {error&&<div role="alert" className="error">{error} <button onClick={refresh}>Try again</button></div>}
      <section className="ledger">
        <div className="ledger-top"><nav aria-label="Ledger views">{['equipment','loans'].map(view=><button key={view} aria-pressed={tab===view} className={tab===view?'selected':''} onClick={()=>{setTab(view);setFilter('all');setQuery('');}}>{view==='equipment'?'Equipment library':'Loan register'}<span>{view==='equipment'?equipment.length:loans.length}</span></button>)}</nav><span className="ledger-caption">A LITTLE ORDER GOES A LONG WAY.</span></div>
        <div className="toolbar"><label className="search"><span>⌕</span><input type="search" aria-label="Search equipment or loans" placeholder={tab==='equipment'?'Search by name, tag, or category…':'Search by borrower or equipment…'} value={query} onChange={e=>setQuery(e.target.value)}/></label><select aria-label="Filter status" value={filter} onChange={e=>setFilter(e.target.value)}><option value="all">All statuses</option>{(tab==='equipment'?[['available','Available'],['on-loan','On loan'],['maintenance','Maintenance'],['retired','Retired']]:[['active','Active'],['overdue','Overdue'],['returned','Returned']]).map(([value,label])=><option key={value} value={value}>{label}</option>)}</select><button className="quiet" onClick={refresh} aria-label="Refresh ledger">↻</button></div>
        {loading?<div className="empty" role="status"><h2>Opening the library…</h2><p>Loading saved equipment and loans.</p></div>:error?<div className="empty"><h2>We couldn’t load the ledger.</h2><p>Check the connection and try again.</p></div>:tab==='equipment'?<><div className="table-head equipment-grid"><span>EQUIPMENT / ASSET TAG</span><span>CATEGORY</span><span>STATUS</span><span>ACTIONS</span></div>{visibleEquipment.map(item=><article className="table-row equipment-grid" key={item.id}><div className="asset"><span className="asset-icon">{item.category.slice(0,2).toUpperCase()}</span><span><strong>{item.name}</strong><small>{item.asset_tag}</small></span></div><span className="category">{item.category}</span><span><span className={'badge '+(item.available?'available':item.condition==='ready'?'active':item.condition)}>{item.available?'Available':item.condition==='ready'?'On loan':item.condition}</span></span><div className="row-actions">{item.available&&<button className="loan-button" onClick={()=>open('loan',item)}>Check out ↗</button>}<button className="quiet" onClick={()=>open('equipment',item)} aria-label={'Edit '+item.name}>Edit</button><button className="quiet delete" onClick={()=>open('delete',item)} aria-label={'Delete '+item.name}>×</button></div></article>)}{!visibleEquipment.length&&<div className="empty"><div className="empty-icon">▤</div><h2>{equipment.length?'No equipment matches.':'Your library starts here.'}</h2><p>{equipment.length?'Try a different search or status.':'Add your first camera, microphone, toolkit, or other shared equipment.'}</p>{!equipment.length&&<button className="primary" onClick={()=>open('equipment')}>Add your first equipment</button>}</div>}</>:<><div className="table-head loan-grid"><span>EQUIPMENT / BORROWER</span><span>DUE DATE</span><span>STATUS</span><span>ACTION</span></div>{visibleLoans.map(item=><article className="table-row loan-grid" key={item.id}><div className="asset"><span className="asset-icon">↔</span><span><strong>{item.equipment_name}</strong><small>{item.asset_tag} · {item.borrower}</small><small>{item.purpose}</small></span></div><span className="due">{item.due_on}{item.returned_on&&<small>Returned {item.returned_on}</small>}</span><span><span className={'badge '+item.status}>{item.status}</span></span><div>{!item.returned_on&&<button className="loan-button" onClick={()=>open('return',item)}>Record return ↙</button>}</div></article>)}{!visibleLoans.length&&<div className="empty"><h2>No loans here yet.</h2><p>Check out available equipment from the library to record a loan.</p></div>}</>}
        <div className="ledger-footer"><span>{tab==='equipment'?visibleEquipment.length:visibleLoans.length} records shown</span><span>Made to be shared. Built to be returned.</span></div>
      </section>
      <footer><span>KitLedger / Equipment, accounted for.</span><span>Yash Agrawal · 24bcs10164</span></footer>
    </main>
    {modal&&<div className="overlay"><section className="modal" role="dialog" aria-modal="true" aria-labelledby="dialog-title"><div className="modal-heading"><div><p className="eyebrow">KITLEDGER / {modal.kind.toUpperCase()}</p><h2 id="dialog-title">{modal.kind==='equipment'?(modal.item?'Edit equipment':'Add equipment'):modal.kind==='loan'?'Check out equipment':modal.kind==='return'?'Record a return':'Delete unused equipment'}</h2></div><button className="quiet" aria-label="Close dialog" onClick={()=>!saving&&setModal(null)}>×</button></div><form onSubmit={save}>
      {modal.kind==='equipment'&&<><label>Asset tag<input autoFocus required name="asset_tag" placeholder="CAM-001" pattern="[A-Z0-9-]+" minLength="2" maxLength="32" value={form.asset_tag} onChange={change}/></label><label>Equipment name<input required name="name" placeholder="Sony mirrorless camera" minLength="2" maxLength="100" value={form.name} onChange={change}/></label><div className="form-grid"><label>Category<input required name="category" placeholder="Camera" minLength="2" maxLength="40" value={form.category} onChange={change}/></label><label>Condition<select name="condition" value={form.condition} onChange={change}><option value="ready">Ready</option><option value="maintenance">Maintenance</option><option value="retired">Retired</option></select></label></div><label>Notes<textarea name="notes" maxLength="500" placeholder="Accessories, storage location, or care instructions" value={form.notes} onChange={change}/></label><p className="hint">Asset tags are unique. Return active loans before maintenance or retirement.</p></>}
      {modal.kind==='loan'&&<><p className="context">{modal.item.name} <span>{modal.item.asset_tag}</span></p><label>Borrower name<input autoFocus required name="borrower" minLength="2" maxLength="100" value={form.borrower} onChange={change}/></label><label>Purpose<input required name="purpose" minLength="3" maxLength="200" placeholder="Workshop or project" value={form.purpose} onChange={change}/></label><label>Due date<input required type="date" name="due_on" value={form.due_on} min={localDate(new Date())} onChange={change}/></label><p className="hint">Loans run for up to 30 days. An item can have only one active loan.</p></>}
      {modal.kind==='return'&&<><p className="context">{modal.item.equipment_name} <span>{modal.item.borrower}</span></p><label>Returned condition<select autoFocus name="condition" value={form.condition} onChange={change}><option value="ready">Ready for the next borrower</option><option value="maintenance">Needs maintenance</option></select></label><p className="hint">The loan stays in the register. Equipment needing maintenance cannot be checked out.</p></>}
      {modal.kind==='delete'&&<p>Delete <strong>{modal.item.name}</strong> ({modal.item.asset_tag})? Equipment with loan history is protected. Retire it instead.</p>}
      {formError&&<div role="alert" className="error">{formError}</div>}
      <div className="modal-actions"><button type="button" disabled={saving} onClick={()=>setModal(null)}>Cancel</button><button className="primary" disabled={saving}>{saving?'Saving…':modal.kind==='equipment'?'Save equipment':modal.kind==='loan'?'Confirm checkout':modal.kind==='return'?'Save return':'Delete equipment'}</button></div>
    </form></section></div>}
  </div>;
}
createRoot(document.getElementById('root')).render(<App/>);
