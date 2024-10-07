import { LightningElement, api } from 'lwc';

export default class TagStateList extends LightningElement {
    
    @api modalClass;
    @api tags= [];
    
    @api
    updatetags(tags) {
        this.tags = tags;
    }
    
    proxyToObj(data) {
        return data ? JSON.parse(JSON.stringify(data)) : '';
    }

    handleRemoveTag(event){
        event.stopPropagation();
        const tagToRemove = event.target.dataset.tag;
        const removeTag = new CustomEvent('remove', {
            detail : tagToRemove
        });
        this.dispatchEvent(removeTag);
    }
}