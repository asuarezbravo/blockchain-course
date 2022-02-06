var crypto = require('crypto');

var hash = crypto.createHash('md5').update("Prueba").digest('hex');
console.log("Hash de 'Prueba':    ", hash);

hash = crypto.createHash('md5').update("Prueba 2").digest('hex');
console.log("Hash de 'Prueba 2':  ", hash);

hash = crypto.createHash('md5').update("Prueba 22").digest('hex');
console.log("Hash de 'Prueba 22': ", hash);