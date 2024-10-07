import { LightningElement, api } from "lwc";

export default class DropdownSelect extends LightningElement {
  isOpen = false;
  highlightCounter = null;
  handleBlurElement = false;
  message = "";
  _value = "";
  _selected = "";
  _location = "";
  @api mainClass;
  @api title;
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

  @api selectClose() {
    this.isOpen = false;
  }

  @api getLocationId(val) {
    if (val) {
      let flag = true,
        locationId = "";
      for (let i = 0; i < this.options.length; i++) {
        if (this.options[i].label.toLowerCase().includes(val.toLowerCase())) {
          flag = false;
          locationId = this.options[i];
        }
      }

      if (!flag) this._location = locationId;
      else this._location = "";
    }
    return this._location;
  }

  @api
  get selectedValue() {
    let selectValue = "";
    if (this._selected) {
      let flag = true;
      for (let i = 0; i < this.options.length; i++) {
        if (
          this.options[i].label
            .toLowerCase()
            .includes(this._selected.toLowerCase())
        ) {
          flag = false;
        }
      }

      if (!flag) {
        //	this.fireEvent(this._selected);
        selectValue = this._selected;
        this.addHighlighted(selectValue);
      }
    }
    return selectValue;
  }

  set selectedValue(val) {
    console.log("inside selected", val);
    this._selected = val;
  }

  @api toggleSelected(option) {
    this.removeHighlighted();
    this.template.querySelector(
      `[data-label="${option}"],.slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown`
    ).style.display = "none";
  }

  @api toggleSelectedValue(opt) {
		this._selected = opt;
    console.log("this--", this.selectedValue)
    this.template.querySelector(".selection__rendered").innerText = opt;
	}

  @api toggleStyle(boolean){
    if(boolean){
      this.template.querySelector('.slds-dropdown_fluid').classList.add('dropdown_width');
      this.template.querySelector('.slds-listbox_vertical').classList.add('listbox_css');
      this.template.querySelector('.dropdown--results').classList.add('listoption_css');
    }else{
      this.template.querySelector('.slds-dropdown_fluid').classList.remove('dropdown_width');
      this.template.querySelector('.slds-listbox_vertical').classList.remove('listbox_css');
      this.template.querySelector('.dropdown--results').classList.remove('listoption_css');
    }
  }

  

  @api label = "Subject";

  _options = [];

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
      options = this.options.filter((op) =>
        op.label.toLowerCase().includes(this.value.toLowerCase())
      );
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

  handleInput() {
    this.isOpen = true;
  }

  fireChange(val, key) {
    this.dispatchEvent(new CustomEvent("change", { detail: { value: val, key : key } }));
    //this._value = ""
  }

  get classes() {
    let classes =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    if (this.isOpen) {
      return classes + " slds-is-open";
    }
    return classes;
  }

  // get inputClasses() {
  // 	let inputClasses = "slds-input slds-combobox__input filter-input";
  // 	if (this.isOpen) {
  // 		return inputClasses + " slds-has-focus";
  // 	}
  // 	return inputClasses;
  // }

  allowBlur() {
    this._cancelBlur = false;
  }

  cancelBlur() {
    this._cancelBlur = true;
  }

  handleDropdownMouseDown() {
    console.log("DropdownMouseDown");
  }

  handleDropdownMouseUp() {
    console.log("DropdownMouseUp");
    this.isOpen = false;
    //this.allowBlur();
  }

  handleMouseUp() {
    //console.log("LEave Div")
    // if (!this._inputHasFocus) {
    this.isOpen = false;
    // }
    //this.allowBlur();
  }

  handleDropdownMouseLeave() {
    console.log("DropdownMouseLeave");
    this.isOpen = false;
    // if (!this._inputHasFocus) {
    // 	this.isOpen = false;
    // }
  }

  handleBlur() {
	//if (!this.isSelection) {
		console.log("handle blur");
		this.handleBlurElement = true;
		//this._inputHasFocus = false;
		if (this._cancelBlur) {
			return;
		}
		this.isOpen = false;

		this.highlightCounter = null;
	//}

    //this.dispatchEvent(new CustomEvent("blur"));
  }

  removeHighlighted() {
    let highlightedList = this.template.querySelectorAll(
      ".slds-listbox__option"
    );
    highlightedList.forEach((option) => {
      //if(option.dataset.label === this._selected){
      //console.log('inside remove', this._selected)
      option.classList.remove("active");
      //}
    });
  }

  @api
  removeHidden(option) {
    console.log("remove--", option);
    this.template.querySelector(
      `[data-label="${option}"],.slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown`
    ).style.display = "flex";
  }

  @api selection(){
    this._value = "";
    this.template.querySelector(".selection__rendered").innerText = this.title;
    this._selected = this._value;
    this.removeHighlighted();
    this._element = undefined
  }

  addHighlighted(selectedVal) {
    let highlightedList = this.template.querySelectorAll(
      ".slds-listbox__option"
    );
    highlightedList.forEach((option) => {
      if (option.dataset.label === selectedVal) {
        //if(this._element === undefined){
        option.classList.add("active");
        //	}
      }
    });
  }

  fireEvent(opt) {
    let highlightedList = this.template.querySelectorAll(
      ".slds-listbox__option"
    );
    highlightedList.forEach((option) => {
      if (option.dataset.label === opt) {
        this.dispatchEvent(
          new CustomEvent("trigger", { detail: { value: option.dataset.id } })
        );
      }
    });
  }

  handleFocus() {
    console.log(this.isOpen, "focus");
    this._inputHasFocus = true;
    this.isOpen = !this.isOpen;
    this.highlightCounter = null;
    //this.removeHighlighted();
    //	console.log(this._element.dataset.label)
    if (this._element !== undefined) {
      this.options.forEach((option) => {
        if (option.label === this._element.dataset.label) {
          //console.log('handleFocus', this._previousElement.dataset.label, this._element.dataset.label)
          this.removeHighlighted();
          this._element.classList.add("active");
        }
      });
    }
    this.dispatchEvent(new CustomEvent("focus"));
  }

  handleSelect(event) {
    console.log("Inside dropdown select");
    //this.allowBlur();
    this._element = event.currentTarget;
    this._previousElement = this._element;
    //this._value = event.currentTarget.dataset.label;
    this._value = "";
    this.template.querySelector(".selection__rendered").innerText =
      event.currentTarget.dataset.label;
    this._selected = event.currentTarget.dataset.label;
    //this.addHighlighted(event.currentTarget.dataset.label);
    this.fireChange(event.currentTarget.dataset.label, event.currentTarget?.dataset.id);
    this.isOpen = false;
  }

  handleContext(event) {
    event.preventDefault();
  }
  handlePaste(event) {
    event.preventDefault();
  }

  highLightOption(options) {
    console.log("highLight-->");
    // eslint-disable-next-line vars-on-top
    var classes =
      "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown";
    // eslint-disable-next-line vars-on-top
    var activeClasses =
      "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small app-dropdown active";
    return options.map((option, index) => {
      var cs = classes;
      var focused = "";
      if (this._selected) {
        if (option.label === this._selected) {
          cs = activeClasses + " slds-has-focus";
          focused = "yes";
        } else {
          if (index === this.highlightCounter) {
            cs = classes + " slds-has-focus";
            focused = "yes";
          }
        }
      } else {
        if (index === this.highlightCounter) {
          cs = classes + " slds-has-focus";
          focused = "yes";
        }
      }

      return { classes: cs, focused, ...option };
    });
  }

  insideDivElement(event) {
    event.stopPropagation();
    return false;
  }

  inputMouseDown(event) {
    event.target.selectionStart = event.target.selectionEnd;
    //event.preventDefault();
  }

  connectedCallback() {
    //this.options.splice(0, 0, ...{id: '', label: this.defaultOption, value: 0})
    const newArr = this.options.map((element) => {
      const o = { ...element };
      if (o.value === 0) {
        o.label = this.defaultOption;
      }
      return o;
    });

    this.message = this.options.length > 0 ? "" : "No records available";

    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.options = newArr;
    //console.log('dropdown-->', JSON.stringify(this.options))
    this.template.ownerDocument.addEventListener(
      "click",
      (this.outsideClick = this.handleMouseUp.bind(this))
    );
	
  }

  disconnectedCallback() {
    this.template.ownerDocument.removeEventListener("click", this.outsideClick);
  }
}