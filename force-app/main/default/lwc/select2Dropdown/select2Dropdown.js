import { LightningElement, api } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
export default class Select2Dropdown extends LightningElement {
    isOpen = false;
	highlightCounter = null;
	handleBlurElement = false;
	message = "";
	_value = "";
	_selected = "";
	_location = '';
	searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
	@api title;
	@api mainClass;
	@api defaultOption;
	@api messageWhenInvalid = "Please type or select a value";
	@api required = false;
	@api minChar = 2;
	@api
	get value() {
		return this._value;
	}

	set value(val) {
		this._value = val;
	}

	@api getLocationId(val){
		if(val){
			let flag = true, locationId = '';
			for(let i = 0; i < this.options.length; i++) {
				if(this.options[i].label.toLowerCase().includes(val.toLowerCase())) {
					flag = false;
					locationId = this.options[i];
				} 
			}

			if(!flag)
				this._location = locationId
			else
			   this._location = ''
		}
		return this._location
	}

	@api
	get selectedValue() {
		let selectValue = '';
		if(this._selected){
			let flag = true;
			for(let i = 0; i < this.options.length; i++) {
				if(this.options[i].label.toLowerCase().includes(this._selected.toLowerCase())) {
					flag = false;
				} 
			}

			if(!flag) {
			//	this.fireEvent(this._selected);
				selectValue = this._selected
				this.addHighlighted(selectValue);
			}
		}
		return selectValue
	}

	set selectedValue(val) {
		console.log('inside selected')
		this._selected = val;
	}

	@api toggleSelected() {
		this._value = "";
		this._selected = this._value;
		this.removeHighlighted();
		this._element = undefined
	}

	@api label = "Subject";

	_options = [
	];

	@api
	get options() {
		return this._options;
	}

	set options(val) { 
		//this._options = {id: '', label: this.defaultOption, value: 0}
		this._options = val || [];
	}


	get tempOptions() {
		let options = this.options;
		if (this.value) {
			//this.options[0]{id: '', label: this.defaultOption, value: 0}
			options = this.options.filter((op) => op.label.toLowerCase().includes(this.value.toLowerCase()));
		}
		return this.highLightOption(options);
	}

	get isInvalid() {
		return this.required && !this.value;
	}

	get formElementClasses() {
		let classes = "slds-form-element";
		if (this.isInvalid) {
			classes += " slds-has-error";
		}
		return classes;
	}

	@api
	setDynamicContentStyle(maxHeight, width) {
		this.refs.ddContent.style.setProperty('max-height', `${maxHeight}`, 'important');
		this.refs.ddContent.style.setProperty('width', `${width}`, 'important');
	}

	handleChange(event) {
		event.stopPropagation();
		console.log('change', event.target.value)
		this._value = event.target.value;
		if(this._value && this._value.length > 0 ) {
			//this._selected = "";
            this.message = '';
            if(this._value.length >= this.minChar) {
                let flag = true;
                for(let i = 0; i < this.options.length; i++) {
                    if(this.options[i].label.toLowerCase().includes(this._value.toLowerCase())) {
                        flag = false;
                    } 
                }
                if(flag) {
                   this.message = "No results found for '" + this._value + "'";
               }
            }
			//this._element.classList.add('active');
        }
		//this._element.classList.add('active');
		//this.fireChange();
	}

	handleInput() {
		this.isOpen = true;
	}

	fireChange(val) {
		this.dispatchEvent(new CustomEvent("change", {detail: {value: val}}));
		//this._value = ""
	}

	get classes() {
		let classes = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
		if (this.isOpen) {
			return classes + " slds-is-open";
		}
		return classes;
	}

	get inputClasses() {
		let inputClasses = "slds-input slds-combobox__input filter-input";
		if (this.isOpen) {
			return inputClasses + " slds-has-focus";
		}
		return inputClasses;
	}

	allowBlur() {
		this._cancelBlur = false;
	}

	cancelBlur() {
		this._cancelBlur = true;
	}

	handleDropdownMouseDown() {
		console.log('DropdownMouseDown');
		this._cancelBlur = true;
	}

	handleDropdownMouseUp() {
		console.log('DropdownMouseUp')
	  //  this.isOpen = false;
		//this.allowBlur();
	}

	handleMouseUp(){
		//console.log("LEave Div")
		// if (!this._inputHasFocus) {
			this.isOpen = false;
		// }
		//this.allowBlur();
	}

	handleDropdownMouseLeave() {
		console.log('DropdownMouseLeave')
		this.isOpen = false;
		// if (!this._inputHasFocus) {
		// 	this.isOpen = false;
		// }
	}

	handleBlur() {
		console.log("handle blur");
		this.handleBlurElement = true;
		//this._inputHasFocus = false;
		if (this._cancelBlur) {
			return;
		}
		this.isOpen = false;
	
		this.highlightCounter = null;
	}

	removeHighlighted(){
		let highlightedList = this.template.querySelectorAll('.slds-listbox__option');
		highlightedList.forEach((option) => {
		//if(option.dataset.label === this._selected){
				option.classList.remove('active');
				console.log('inside remove', option)
		//}
		})
		console.log("high=---", highlightedList)
	}

	addHighlighted(selectedVal){
		let highlightedList = this.template.querySelectorAll('.slds-listbox__option');
		highlightedList.forEach((option) => {
			if(option.dataset.label === selectedVal){
				//if(this._element === undefined){
					option.classList.add('active');
			//	}
			}
		})
	}

	fireEvent(opt){
		let highlightedList = this.template.querySelectorAll('.slds-listbox__option');
		highlightedList.forEach((option) => {
			if(option.dataset.label === opt){
				this.dispatchEvent(new CustomEvent("trigger", {detail: {value: option.dataset.id}}));
			}
		})
	}

	handleFocus() {
		this._inputHasFocus = true;
		this.isOpen = !this.isOpen;
		this.highlightCounter = null;
		//this.removeHighlighted();
	//	console.log(this._element.dataset.label)
		if(this._element !== undefined){
			this.options.forEach((option) => {
				if (option.label === this._element.dataset.label) {
				//console.log('handleFocus', this._previousElement.dataset.label, this._element.dataset.label)
				    this.removeHighlighted();
					this._element.classList.add('active');
				}
			});
		}
		this.dispatchEvent(new CustomEvent("focus"));
	}

	handleSelect(event) {
		//this.allowBlur();
		this._element = event.currentTarget;
		this._previousElement = this._element;
		//this._value = event.currentTarget.dataset.label;
		this._value = "";
		this.template.querySelector('.selection__rendered').innerText = event.currentTarget.dataset.label;
		this._selected = event.currentTarget.dataset.label;
		//this.addHighlighted(event.currentTarget.dataset.label);
		this.fireChange(event.currentTarget.dataset.label);
		this.isOpen = false;
		
	}

	handleKeyDown(event) {
		console.log("key down--")
		if (event.key === "Escape") {
			this.isOpen = !this.isOpen;
			this.highlightCounter = null;
		} else if (event.key === "Enter" && this.isOpen) {
			if (this.highlightCounter !== null) {
				this.isOpen = false;
				this.allowBlur();
				//this._value = this.tempOptions[this.highlightCounter].value;
				//this.fireChange();
			}
		} else if (event.key === "Enter") {
			this.handleFocus();
		}

		if (event.key === "ArrowDown" || event.key === "PageDown") {
			this._inputHasFocus = true;
			this.isOpen = true;
			this.highlightCounter = this.highlightCounter === null ? 0 : this.highlightCounter + 1;
		} else if (event.key === "ArrowUp" || event.key === "PageUp") {
			this._inputHasFocus = true;
			this.isOpen = true;
			this.highlightCounter = this.highlightCounter === null || this.highlightCounter === 0 ? this.tempOptions.length - 1 : this.highlightCounter - 1;
		}

		if (event.key === "ArrowDown" || event.key === "ArrowUp") {
			this.highlightCounter = Math.abs(this.highlightCounter) % this.tempOptions.length;
		}

		if (event.key === "Home") {
			this.highlightCounter = 0;
		} else if (event.key === "End") {
			this.highlightCounter = this.tempOptions.length - 1;
		}
	}

	handleContext(event){
		event.preventDefault();
	}
	handlePaste(event){
		event.preventDefault();
	}

	highLightOption(options) {
		console.log("highLight-->")
		// eslint-disable-next-line vars-on-top
		var classes = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown";
		// eslint-disable-next-line vars-on-top
		var activeClasses = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown active";
		return options.map((option, index) => {
			var cs = classes;
			var focused = "";
			if(this._selected){
				if(option.label === this._selected){
					cs = activeClasses + " slds-has-focus";
					focused = "yes";
				}else{
					if (index === this.highlightCounter) {
						cs = classes + " slds-has-focus";
						focused = "yes";
					}
				}
			}else{
				if (index === this.highlightCounter) {
					cs = classes + " slds-has-focus";
					focused = "yes";
				}
			}
		
			return {classes: cs, focused, ...option}; 
		});

	}

	insideDivElement(event){
		event.stopPropagation();
			return false;
	}

	inputMouseDown(event){
		event.target.selectionStart = event.target.selectionEnd;
		//event.preventDefault();
	}

	connectedCallback(){
		//this.options.splice(0, 0, ...{id: '', label: this.defaultOption, value: 0})
		const newArr = this.options.map((element=>{
			const o = {...element};
			if(o.value === 0){
				o.label = this.defaultOption
			}
			return o;
		}))

		// eslint-disable-next-line @lwc/lwc/no-api-reassignments
		this.options = newArr;
		//console.log('dropdown-->', JSON.stringify(this.options))
		this.template.ownerDocument.addEventListener('click', this.outsideClick = this.handleMouseUp.bind(this));
	}

	renderedCallback(){
		this.template.querySelector('.slds-combobox__input').addEventListener('contextmenu', this.handleContext.bind(this));
		this.template.querySelector('.slds-combobox__input').addEventListener('cut', this.handlePaste.bind(this));
	}

	disconnectedCallback() {
        this.template.ownerDocument.removeEventListener('click', this.outsideClick);
    }
	
}