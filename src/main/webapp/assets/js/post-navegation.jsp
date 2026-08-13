(function () {
function csrf() {
const field = document.querySelector('input[name="csrfToken"]');
return field ? field.value : '';
}

function postTo(url, values, target) {
const destination = new URL(url, window.location.href);
const form = document.createElement('form');
form.method = 'post';
form.action = destination.pathname;
form.style.display = 'none';
if (target) form.target = target;
destination.searchParams.forEach((value, name) => add(form, name, value));
Object.entries(values || {}).forEach(([name, value]) => add(form, name, value));
if (!form.querySelector('[name="csrfToken"]')) add(form, 'csrfToken', csrf());
document.body.appendChild(form);
form.submit();
}

function add(form, name, value) {
const input = document.createElement('input');
input.type = 'hidden';
input.name = name;
input.value = value == null ? '' : value;
form.appendChild(input);
}

async function privateFile(token, download) {
const body = new URLSearchParams({fileRef: token, csrfToken: csrf()});
if (download) body.set('descargar', '1');
const response = await fetch(document.body.dataset.contextPath + '/archivo', {
method: 'POST',
credentials: 'same-origin',
headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-Token': csrf()},
body
});
if (!response.ok) throw new Error('No fue posible abrir el archivo.');
const blob = await response.blob();
const objectUrl = URL.createObjectURL(blob);
if (download) {
const link = document.createElement('a');
link.href = objectUrl;
link.download = '';
link.click();
} else {
window.open(objectUrl, '_blank', 'noopener');
}
window.setTimeout(() => URL.revokeObjectURL(objectUrl), 60000);
}

document.addEventListener('DOMContentLoaded', function () {
document.body.dataset.contextPath = document.body.dataset.contextPath ||
document.querySelector('meta[name="context-path"]')?.content || '';
document.querySelectorAll('img[data-private-image]').forEach(async image => {
try {
const body = new URLSearchParams({fileRef: image.dataset.privateImage, csrfToken: csrf()});
const response = await fetch(document.body.dataset.contextPath + '/archivo', {
method: 'POST', credentials: 'same-origin',
headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-Token': csrf()}, body
});
if (!response.ok) return;
image.src = URL.createObjectURL(await response.blob());
} catch (error) {
image.alt = 'Evidencia no disponible';
}
});
});

document.addEventListener('click', function (event) {
const fileButton = event.target.closest('[data-private-file]');
if (fileButton) {
event.preventDefault();
privateFile(fileButton.dataset.privateFile, fileButton.hasAttribute('data-download'))
.catch(error => window.alert(error.message));
return;
}
const button = event.target.closest('[data-post-url]');
if (button) {
event.preventDefault();
postTo(button.dataset.postUrl, button.dataset.postRef ? {ref: button.dataset.postRef} : {}, button.dataset.target);
return;
}
const link = event.target.closest('a[href]');
if (!link || link.hasAttribute('data-public-get')) return;
const href = link.getAttribute('href');
if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')
|| href.startsWith('javascript:') || href.startsWith('blob:')) return;
const destination = new URL(link.href, window.location.href);
if (destination.origin !== window.location.origin) return;
event.preventDefault();
postTo(destination.href, {}, link.target || '');
});

window.awgvaPost = postTo;
})();