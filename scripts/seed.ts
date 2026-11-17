import { resetDemo, snapshot } from '../src/lib/db';
resetDemo();
const state=snapshot();
console.log(`Seeded ${state.organizations.length} organizations, ${state.listings.length} listings, ${state.reservations.length} reservations.`);
