'use strict'
exports.handler = (event, context, callback) => {
    //console.log(event)
    /* Process the list of records and drop those containing Default_Action */
    const output = event.records.map((record) => {
        
        const entry = (Buffer.from(record.data, 'base64')).toString('utf8');
        var jsonEntry = JSON.parse(entry);
        //console.log(jsonEntry.httpRequest.headers)
        const headers = jsonEntry.httpRequest.headers;
        let cookie;
        for (let i =0; i < headers.length; i++) {
            const item = headers[i];
            if (item.name == 'cookie') {
            cookie = item.value;
            break;
            }
        }
        
        // if cookie existed in the request 
        if ((typeof cookie !== 'undefined')){
        const cookieArray = cookie.split(';');
        
        //console.log(cookieArray)
        for (let j=0; j < cookieArray.length; j++) {
            const item = cookieArray[j].trim();
            if (item.indexOf('_imp_apg_r_') == 0) {
                const name = item.split('=')[0];
                const value = item.split('=')[1];
                try {
                    var deviceId = JSON.parse(decodeURIComponent(value));
                    //console.log(decodeURIComponent(value))
                  } catch (e) { // catches a malformed cookie
                    console.error(e);
                  }
                jsonEntry["deviceidA"] = deviceId.diA;
                jsonEntry["deviceidB"] = deviceId.diB;
            }
            //console.log(jsonEntry);
        }
        let objJsonStr = JSON.stringify(jsonEntry);
        let objJsonB64 = Buffer.from(objJsonStr).toString("base64");
        //console.log(jsonEntry)
        return {
            recordId: record.recordId,
            result: 'Ok',
            data: objJsonB64,
        };
        }
    });

    console.log(`Processing completed.  Successful records ${output.length}.`);
    callback(null, { records: output });
};