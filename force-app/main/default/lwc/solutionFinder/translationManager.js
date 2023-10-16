//import Application_Design from '@salesforce/label/c.Application_Design';
//import App_Design_Functionality from '@salesforce/label/c.App_Design_Functionality';

const getTranslations = () => {
    return parseLabels(getLabels());
}

const getLabels = () => {
    return {
        //Application_Design,
        //App_Design_Functionality
    }
}

const parseLabels = (labels) => {
    let translations = {};
    var lines;
    for (const [key, value] of Object.entries(labels)) {
        let obj = JSON.parse(value);
        translations[key] = obj;
    }
    return translations;
}

export { getTranslations };