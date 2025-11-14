function isNonEmptyString(v){return typeof v==='string'&&v.trim().length>0}
function isPositiveNumber(v){return v!==null&&v!==undefined&&!isNaN(v)&&Number(v)>=0}
function isPositiveInt(v){return Number.isInteger(Number(v))&&Number(v)>0}

function result(errors){return {ok: errors.length===0, errors}}

exports.validateRegister=(b)=>{const e=[];if(!isNonEmptyString(b.name))e.push('name is required');if(!isNonEmptyString(b.email)||!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(b.email))e.push('valid email is required');if(!isNonEmptyString(b.password)||String(b.password).length<6)e.push('password min 6 chars');if(b.role&&!(b.role==='admin'))e.push('invalid role');return result(e)}
exports.validateLogin=(b)=>{const e=[];if(!isNonEmptyString(b.email))e.push('email is required');if(!isNonEmptyString(b.password))e.push('password is required');return result(e)}

exports.validateProductCreate=(b)=>{const e=[];if(!isNonEmptyString(b.product_name))e.push('product_name is required');if(!isPositiveNumber(b.product_price))e.push('product_price must be number >= 0');if(!isNonEmptyString(b.product_unit))e.push('product_unit is required');return result(e)}
exports.validateProductUpdate=(b)=>{const e=[];if(b.product_name!==undefined&&!isNonEmptyString(b.product_name))e.push('product_name must be non-empty');if(b.product_price!==undefined&&!isPositiveNumber(b.product_price))e.push('product_price must be number >= 0');if(b.product_unit!==undefined&&!isNonEmptyString(b.product_unit))e.push('product_unit must be non-empty');if(Object.keys(b).filter(k=>['product_name','product_price','product_unit'].includes(k)).length===0)e.push('no updatable fields provided');return result(e)}

exports.validateCustomerCreate=(b)=>{const e=[];if(!isNonEmptyString(b.customer_name))e.push('customer_name is required');if(!isNonEmptyString(b.customer_address))e.push('customer_address is required');if(!isNonEmptyString(b.phone_no))e.push('phone_no is required');return result(e)}
exports.validateCustomerUpdate=(b)=>{const e=[];const keys=['customer_name','customer_address','phone_no'];if(keys.every(k=>b[k]===undefined))e.push('no updatable fields provided');if(b.customer_name!==undefined&&!isNonEmptyString(b.customer_name))e.push('customer_name must be non-empty');if(b.customer_address!==undefined&&!isNonEmptyString(b.customer_address))e.push('customer_address must be non-empty');if(b.phone_no!==undefined&&!isNonEmptyString(b.phone_no))e.push('phone_no must be non-empty');return result(e)}

exports.validateDeliveryCreate=(b)=>{const e=[];if(!isPositiveInt(b.customer_id))e.push('customer_id must be positive integer');if(!isPositiveInt(b.product_id))e.push('product_id must be positive integer');if(!isPositiveInt(b.product_quantity))e.push('product_quantity must be positive integer');if(!isNonEmptyString(b.delivery_day))e.push('delivery_day is required');return result(e)}
exports.validateDeliveryUpdate=(b)=>{const e=[];const keys=['customer_id','product_id','product_quantity','delivery_day'];if(keys.every(k=>b[k]===undefined))e.push('no updatable fields provided');if(b.customer_id!==undefined&&!isPositiveInt(b.customer_id))e.push('customer_id must be positive integer');if(b.product_id!==undefined&&!isPositiveInt(b.product_id))e.push('product_id must be positive integer');if(b.product_quantity!==undefined&&!isPositiveInt(b.product_quantity))e.push('product_quantity must be positive integer');if(b.delivery_day!==undefined&&!isNonEmptyString(b.delivery_day))e.push('delivery_day must be non-empty');return result(e)}

exports.validatePaymentCreate=(b)=>{const e=[];if(!isPositiveInt(b.customer_id))e.push('customer_id must be positive integer');if(!isPositiveNumber(b.total_amount))e.push('total_amount must be number >= 0');if(!isPositiveNumber(b.paid_amount))e.push('paid_amount must be number >= 0');return result(e)}
exports.validatePaymentUpdate=(b)=>{const e=[];const keys=['customer_id','total_amount','paid_amount'];if(keys.every(k=>b[k]===undefined))e.push('no updatable fields provided');if(b.customer_id!==undefined&&!isPositiveInt(b.customer_id))e.push('customer_id must be positive integer');if(b.total_amount!==undefined&&!isPositiveNumber(b.total_amount))e.push('total_amount must be number >= 0');if(b.paid_amount!==undefined&&!isPositiveNumber(b.paid_amount))e.push('paid_amount must be number >= 0');return result(e)}

// Add at bottom

exports.validateCustomerCreate = (b) => {
  const e = [];
  if (!b || typeof b !== 'object') e.push('invalid body');
  if (!b.customer_name) e.push('customer_name is required');
  if (!b.customer_address) e.push('customer_address is required');
  if (!b.phone_no) e.push('phone_no is required');
  return result(e);
};

exports.validateCustomerUpdate = (b) => {
  const e = [];
  if (b.customer_name !== undefined && !isNonEmptyString(b.customer_name)) e.push('customer_name must be non-empty');
  if (b.customer_address !== undefined && !isNonEmptyString(b.customer_address)) e.push('customer_address must be non-empty');
  if (b.phone_no !== undefined && !isNonEmptyString(b.phone_no)) e.push('phone_no must be non-empty');
  return result(e);
};

exports.validateCustomerProductCreate = (b) => {
  const e = [];
  if (!b) e.push('invalid body');
  if (!isPositiveInt(b.customer_id)) e.push('customer_id required');
  if (!isPositiveInt(b.product_id)) e.push('product_id required');
  if (!isPositiveInt(b.quantity)) e.push('quantity must be positive int');
  if (!isPositiveNumber(b.price)) e.push('price must be number >= 0');
  if (!isNonEmptyString(b.unit)) e.push('unit is required');
  if (!isNonEmptyString(b.frequency)) e.push('frequency is required');
  return result(e);
};

exports.validateCustomerProductUpdate = (b) => {
  const e = [];
  if (b.quantity !== undefined && !isPositiveInt(b.quantity)) e.push('quantity must be positive int');
  if (b.price !== undefined && !isPositiveNumber(b.price)) e.push('price must be number >= 0');
  if (b.unit !== undefined && !isNonEmptyString(b.unit)) e.push('unit must be non-empty');
  if (b.frequency !== undefined && !isNonEmptyString(b.frequency)) e.push('frequency must be non-empty');
  return result(e);
};