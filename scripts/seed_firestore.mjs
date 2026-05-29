/**
 * Firebase Firestore Seed Script
 * ================================
 *
 * Populates Firestore with realistic sample data for the Duka Book app.
 * Data is stored in top-level collections (books, customers, sales)
 * shared by all staff members.
 *
 * Prerequisites:
 *   1. Node.js 18+ installed
 *   2. Firebase Admin SDK key (service account JSON):
 *      - Go to Firebase Console → Project Settings → Service Accounts
 *      - Click "Generate New Private Key" → save as service-account.json
 *      - Place it in this `scripts/` folder
 *   3. Run: npm install firebase-admin
 *
 * Usage:
 *   node seed_firestore.mjs
 *
 * This will create:
 *   - 12 books (African literature + popular titles)
 *   - 8 customers (Ugandan names, Kampala area)
 *   - 18+ sales with realistic dates and quantities
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// ─── CONFIGURATION ────────────────────────────────────────────

const __dirname = dirname(fileURLToPath(import.meta.url));
const SERVICE_ACCOUNT_PATH = join(__dirname, 'service-account.json');

// ─── INIT FIREBASE ADMIN ──────────────────────────────────────

let serviceAccount;
try {
  serviceAccount = JSON.parse(readFileSync(SERVICE_ACCOUNT_PATH, 'utf-8'));
} catch (err) {
  console.error(
    `❌ Could not read ${SERVICE_ACCOUNT_PATH}\n` +
      '   Download your service account key from Firebase Console →\n' +
      '   Project Settings → Service Accounts → Generate New Private Key\n' +
      `   and save it as "${SERVICE_ACCOUNT_PATH}".`
  );
  process.exit(1);
}

const app = initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore(app);

// ─── SAMPLE DATA ──────────────────────────────────────────────

const books = [
  { title: 'Things Fall Apart', author: 'Chinua Achebe', category: 'Fiction', price: 25000, stock: 20 },
  { title: 'The River and the Source', author: 'Margaret Ogola', category: 'Fiction', price: 18000, stock: 3 },
  { title: 'Weep Not Child', author: "Ngũgĩ wa Thiong'o", category: 'Fiction', price: 20000, stock: 8 },
  { title: 'Half of a Yellow Sun', author: 'Chimamanda Ngozi Adichie', category: 'Fiction', price: 30000, stock: 12 },
  { title: 'Born a Crime', author: 'Trevor Noah', category: 'Non-Fiction', price: 35000, stock: 15 },
  { title: 'A Brief History of Time', author: 'Stephen Hawking', category: 'Science', price: 45000, stock: 2 },
  { title: 'The Art of War', author: 'Sun Tzu', category: 'Non-Fiction', price: 15000, stock: 25 },
  { title: 'The Origin of Species', author: 'Charles Darwin', category: 'Science', price: 55000, stock: 1 },
  { title: 'The Diary of a Young Girl', author: 'Anne Frank', category: 'History', price: 22000, stock: 7 },
  { title: 'Matilda', author: 'Roald Dahl', category: 'Children', price: 12000, stock: 30 },
  { title: 'The Hobbit', author: 'J.R.R. Tolkien', category: 'Fiction', price: 28000, stock: 5 },
  { title: 'Long Walk to Freedom', author: 'Nelson Mandela', category: 'History', price: 38000, stock: 4 },
];

const customers = [
  { name: 'Alice Nakato', phone: '0701234567', location: 'Kampala' },
  { name: 'Bob Ochieng', phone: '0787654321', location: 'Jinja' },
  { name: 'Catherine Mbabazi', phone: '0771122334', location: 'Mbale' },
  { name: 'David Senkumba', phone: '0755443322', location: 'Entebbe' },
  { name: 'Esther Auma', phone: '0709988776', location: 'Gulu' },
  { name: 'Frank Mugisha', phone: '0788123456', location: 'Kampala' },
  { name: 'Grace Nambi', phone: '0777555666', location: 'Mbarara' },
  { name: 'Henry Wasswa', phone: '0755001122', location: 'Kampala' },
];

function getRandomSaleDate() {
  // Random date within the last 60 days
  const daysAgo = Math.floor(Math.random() * 60);
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  date.setHours(8 + Math.floor(Math.random() * 10)); // 8am–6pm
  date.setMinutes(Math.floor(Math.random() * 60));
  date.setSeconds(0);
  date.setMilliseconds(0);
  return date;
}

function generateSales(bookMap) {
  const salesData = [
    { bookIdx: 0, qty: 2 },
    { bookIdx: 0, qty: 1 },
    { bookIdx: 1, qty: 1 },
    { bookIdx: 2, qty: 3 },
    { bookIdx: 3, qty: 1 },
    { bookIdx: 4, qty: 2 },
    { bookIdx: 5, qty: 1 },
    { bookIdx: 6, qty: 5 },
    { bookIdx: 7, qty: 1 },
    { bookIdx: 8, qty: 1 },
    { bookIdx: 9, qty: 4 },
    { bookIdx: 10, qty: 2 },
    { bookIdx: 11, qty: 1 },
    { bookIdx: 0, qty: 1 },
    { bookIdx: 3, qty: 2 },
    { bookIdx: 4, qty: 1 },
    { bookIdx: 9, qty: 3 },
    { bookIdx: 6, qty: 2 },
  ];

  return salesData.map((s) => {
    const book = books[s.bookIdx];
    const id = bookMap.get(book.title);
    return {
      bookId: id,
      bookTitle: book.title,
      quantity: s.qty,
      totalPrice: book.price * s.qty,
      date: getRandomSaleDate(),
    };
  });
}

// ─── MAIN ─────────────────────────────────────────────────────

async function main() {
  console.log('🚀 Seeding Firestore for Duka Book...\n');
  console.log('   Top-level collections: books, customers, sales\n');

  const batch = db.batch();
  const bookMap = new Map(); // title → docId

  // 1. Write books
  console.log('📚 Adding books to /books/ ...');
  for (const book of books) {
    const ref = db.collection('books').doc();
    batch.set(ref, book);
    bookMap.set(book.title, ref.id);
    console.log(`   - ${book.title} (${book.author}) — UGX ${book.price.toLocaleString()}`);
  }

  // 2. Write customers
  console.log('\n👥 Adding customers to /customers/ ...');
  for (const customer of customers) {
    const ref = db.collection('customers').doc();
    batch.set(ref, customer);
    console.log(`   - ${customer.name} (${customer.phone}) — ${customer.location}`);
  }

  // 3. Write sales
  console.log('\n🧾 Adding sales to /sales/ ...');
  const sales = generateSales(bookMap);
  for (const sale of sales) {
    const ref = db.collection('sales').doc();
    batch.set(ref, sale);
    console.log(`   - ${sale.bookTitle} × ${sale.quantity} = UGX ${sale.totalPrice.toLocaleString()}`);
  }

  // 4. Commit
  console.log('\n💾 Committing batch write...');
  await batch.commit();

  console.log('\n──────────────────────────────────────────────');
  console.log('✅  Seeding complete!');
  console.log(`   Books:     ${books.length}`);
  console.log(`   Customers: ${customers.length}`);
  console.log(`   Sales:     ${sales.length}`);
  console.log('──────────────────────────────────────────────\n');
  process.exit(0);
}

main().catch((err) => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});