let debounceTimer;

const callMethodDebounce = (argumentJson,callBack,doneTypingInterval) =>{
    console.info('searchUsingDebounce called');
    let data = [];
    if(debounceTimer){
        console.info('Timer Reset');
        clearTimeout(debounceTimer);
    }
    return new Promise((resolve) =>{
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        debounceTimer = setTimeout(() => {
            console.info('Make Call to Server');
            resolve(callBack(argumentJson).then((result) => {
                data =  result;
                return data;
            }))
        }, doneTypingInterval);
        console.info('Timer Value '+debounceTimer)
    }) 
}
const callMethodThrottling = (argumentJson,callback,doneTypingInterval) =>{
    console.info('searchUsingThrottling called');
    let throttleTimer;
    let data = [];
    if (throttleTimer) {
        console.info('Timer Reset');
        return;
    }
    // eslint-disable-next-line consistent-return
    return new Promise((resolve) =>{
        throttleTimer = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            console.info('Make Call to Server');
            resolve(callback(argumentJson).then((result) => {
                data =  result;
                return data;
            }));
            throttleTimer = false;
        }, doneTypingInterval);
        console.info('Timer Done ')
    })
}
const filterArrayWithDebounce = (argumentJson,doneTypingInterval,records) =>{
    let data = [];
    if(debounceTimer){
        console.info('Timer Reset');
        clearTimeout(debounceTimer);
    }
    return new Promise((resolve) =>{
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        debounceTimer = setTimeout(() => {
                console.info('Make search in array');
                records.forEach((record) => {
                    if(record.name.toLowerCase().includes(argumentJson)){
                        data.push(record);
                    }
                })
                resolve(data);
            
        },doneTypingInterval);
    })
}
const filterArrayWithThrottle = (argumentJson,doneTypingInterval,records) =>{
    console.info('searchUsingThrottling called');
    let throttleTimer;
    let data = [];
    if (throttleTimer) {
        console.info('Timer Reset');
        return;
    }
    // eslint-disable-next-line consistent-return
    return new Promise((resolve) =>{
        throttleTimer = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            records.forEach((record) => {
                if(record.name.toLowerCase().includes(argumentJson)){
                    data.push(record);
                }
                if(record.name.toLowerCase().includes(argumentJson)){
                    data.push(record);
                }
            })
            resolve(data);
        },doneTypingInterval);
    })
}

const debounceCustomEvent = (eventParam) =>{
    if(debounceTimer){
        clearTimeout(debounceTimer);
    }
    return new Promise((resolve) =>{
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        debounceTimer = setTimeout(() => {
            console.info('Make custom event fire');
                resolve(
                    dispatchEvent(
                        new CustomEvent(
                            this.eventName,{
                            detail:eventParam
                            }
                        )
                    )
                )
        }, this.doneTypingInterval)
        console.log('done Time');
    })
}


export {
    callMethodDebounce,
    callMethodThrottling,
    filterArrayWithDebounce,
    filterArrayWithThrottle,
    debounceCustomEvent
};