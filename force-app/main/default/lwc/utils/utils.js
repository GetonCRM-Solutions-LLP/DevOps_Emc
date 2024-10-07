const events  = (component, param) => {
    const e = new CustomEvent('navigate', {detail: param});
    component.dispatchEvent(e);
}

const skipEvents  = (component, param) => {
    const e = new CustomEvent('skip', {detail: param});
    component.dispatchEvent(e);
}

const backEvents  = (component, param) => {
    const e = new CustomEvent('back', {detail: param});
    component.dispatchEvent(e);
}

const nextSkipEvents  = (component, param) => {
    const e = new CustomEvent('nextskip', {detail: param});
    component.dispatchEvent(e);
}

const openEvents  = (component, param) => {
    const e = new CustomEvent('open', {detail: param});
    component.dispatchEvent(e);
}

const toastEvents  = (component, param) => {
    const e = new CustomEvent('toast', {detail: param});
    component.dispatchEvent(e);
}

const modalEvents  = (component, param) => {
    const e = new CustomEvent('modal', {detail: param});
    component.dispatchEvent(e);
}

const searchEvents  = (component, param) => {
    const e = new CustomEvent('search', {detail: param});
    component.dispatchEvent(e);
}

const pageEvents  = (component, param) => {
    const e = new CustomEvent('pagecount', {detail: param});
    component.dispatchEvent(e);
}

const syncEvents  = (component, param) => {
    const e = new CustomEvent('syncdone', {detail: param});
    component.dispatchEvent(e);
}

const toggleEvents  = (component, param) => {
    const e = new CustomEvent('toggle', {detail: param});
    component.dispatchEvent(e);
}

export {events, skipEvents, backEvents, nextSkipEvents, openEvents, toastEvents, modalEvents, searchEvents, pageEvents, syncEvents, toggleEvents}