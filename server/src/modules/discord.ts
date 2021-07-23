import fetch from 'cross-fetch';
/**
* home made discord api for fnfnet
*
* @param {string} send Send text to desired webhook
*/
export class discord {
    send(url:string, message:String){
        var data = { content: message.replace("@everyone", "@iamsuperfunny").replace("@here", "@iamsuperfunny"), allowed_mentions: false };

        //POST request with body equal on data in JSON format
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });
    }
}