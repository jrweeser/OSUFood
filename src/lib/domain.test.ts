import { describe, expect, it } from 'vitest';
import { canCancel, canComplete, listingSchema, listingStatus, remaining } from './domain';
const input={title:'Fresh boxes',description:'Fresh food boxes',category:'Produce',quantity:20,unit:'boxes',pickupLocation:'North desk',pickupStart:new Date(Date.now()+3600000).toISOString(),pickupEnd:new Date(Date.now()+7200000).toISOString(),storageRequirements:'Keep cool',allergenInformation:'Ask source',organizationId:'north'};
describe('domain validation and rules',()=>{
 it('accepts positive quantities and rejects zero/negative/fractions',()=>{expect(listingSchema.safeParse(input).success).toBe(true);for(const quantity of [0,-1,1.5])expect(listingSchema.safeParse({...input,quantity}).success).toBe(false)});
 it('requires a valid future pickup window',()=>{expect(listingSchema.safeParse({...input,pickupEnd:input.pickupStart}).success).toBe(false);expect(listingSchema.safeParse({...input,pickupEnd:new Date(Date.now()-3600000).toISOString()}).success).toBe(false)});
 it('subtracts reserved quantity without overbooking',()=>{expect(remaining(20,5)).toBe(15);expect(()=>remaining(20,21)).toThrow();expect(()=>remaining(20,0)).toThrow()});
 it('derives listing status consistently',()=>{expect(listingStatus(20,20,input.pickupEnd,false)).toBe('AVAILABLE');expect(listingStatus(15,20,input.pickupEnd,false)).toBe('PARTIALLY_RESERVED');expect(listingStatus(0,20,input.pickupEnd,false)).toBe('FULLY_RESERVED');expect(listingStatus(20,20,input.pickupEnd,true)).toBe('CLOSED');expect(listingStatus(20,20,new Date(0).toISOString(),false)).toBe('EXPIRED')});
 it('limits cancellation and completion eligibility',()=>{expect(canCancel('RESERVED',input.pickupEnd)).toBe(true);expect(canCancel('COMPLETED',input.pickupEnd)).toBe(false);expect(canCancel('RESERVED',new Date(0).toISOString())).toBe(false);expect(canComplete('RESERVED')).toBe(true);expect(canComplete('COMPLETED')).toBe(false)});
});
