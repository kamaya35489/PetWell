import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";
import { getFirestore, collection, doc, addDoc, setDoc, getDocs, updateDoc, deleteDoc, onSnapshot, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

// 🔥 REPLACE WITH YOUR FIREBASE CONFIG
const firebaseConfig = {
  apiKey: "AIzaSyB_NbT-zJ572-SHdE7t6pDAd2EOwJ2zMes",
  authDomain: "petwell-24602.firebaseapp.com",
  projectId: "petwell-24602",
  storageBucket: "petwell-24602.firebasestorage.app",
  messagingSenderId: "983597733024",
  appId: "1:983597733024:web:e1a5d520739c0199aaa5c5"
};

const app=initializeApp(firebaseConfig);
export const auth=getAuth(app);
export const db=getFirestore(app);
export const loginUser=(e,p)=>signInWithEmailAndPassword(auth,e,p);
export const registerUser=(e,p)=>createUserWithEmailAndPassword(auth,e,p);
export const logoutUser=()=>signOut(auth);
export const onAuth=cb=>onAuthStateChanged(auth,cb);
export const getDocs2=(col)=>getDocs(collection(db,col));
export const updateDoc2=(col,id,d)=>updateDoc(doc(db,col,id),d);
export const deleteDoc2=(col,id)=>deleteDoc(doc(db,col,id));
export const watch=(col,cb)=>onSnapshot(collection(db,col),cb);

export const addDocWithID = async (col, data) => {
  const snap = await getDocs(collection(db, col));
  const count = snap.size + 1;
  const prefix = col.replace('petOwners','owner').replace('bookings','booking')
    .replace('payments','payment').replace('pets','pet')
    .replace('feedback','feedback').replace('orders','order')
    .replace('products','product').replace('carts','cart');
  const newID = prefix + String(count).padStart(3, '0');
  await setDoc(doc(db, col, newID), {...data, createdAt: serverTimestamp()});
  return newID;
};
