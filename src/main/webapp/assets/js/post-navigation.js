(function () {
    const READ_ONLY_ROUTES = new Set([
        '/inicio',
        '/nueva-solicitud',
        '/mis-solicitudes',
        '/solicitud-previa',
        '/detalle-solicitud',
        '/carta-responsiva',
        '/oficio-autorizacion',
        '/subir-solicitud-firmada',
        '/subir-carta-firmada',
        '/reportes-docente',
        '/historico-docente',
        '/reporte-docente',
        '/cambiar-contrasena'
    ]);

    function csrf() {
        const field = document.querySelector('input[name="csrfToken"]');
        return field ? field.value : '';
    }

    function contextPath() {
        return document.body.dataset.contextPath ||
            document.querySelector('meta[name="context-path"]')?.content || '';
    }

    function routeOf(url) {
        const destination = new URL(url, window.location.href);
        const context = contextPath();
        if (context && destination.pathname.startsWith(context + '/')) {
            return destination.pathname.substring(context.length);
        }
        return destination.pathname;
    }

    function isReadOnly(url) {
        return READ_ONLY_ROUTES.has(routeOf(url));
    }

    function add(form, name, value) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value == null ? '' : value;
        form.appendChild(input);
    }

    function getTo(url, values, target) {
        const destination = new URL(url, window.location.href);
        Object.entries(values || {}).forEach(([name, value]) => {
            destination.searchParams.set(name, value == null ? '' : value);
        });
        if (target && target !== '_self') {
            window.open(destination.href, target, 'noopener');
            return;
        }
        window.location.assign(destination.href);
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

    function navigate(url, values, target) {
        if (isReadOnly(url)) {
            getTo(url, values, target);
            return;
        }
        postTo(url, values, target);
    }

    async function privateFile(token, download) {
        const body = new URLSearchParams({fileRef: token, csrfToken: csrf()});
        if (download) body.set('descargar', '1');
        const response = await fetch(contextPath() + '/archivo', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-CSRF-Token': csrf()
            },
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

    async function loadPrivateImage(image) {
        try {
            const body = new URLSearchParams({
                fileRef: image.dataset.privateImage,
                csrfToken: csrf()
            });
            const response = await fetch(contextPath() + '/archivo', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': csrf()
                },
                body
            });
            if (!response.ok) return;
            image.src = URL.createObjectURL(await response.blob());
        } catch (error) {
            image.alt = 'Evidencia no disponible';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.body.dataset.contextPath = contextPath();
        document.querySelectorAll('img[data-private-image]').forEach(loadPrivateImage);
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
            navigate(
                button.dataset.postUrl,
                button.dataset.postRef ? {ref: button.dataset.postRef} : {},
                button.dataset.target
            );
            return;
        }

        const link = event.target.closest('a[href]');
        if (!link || link.hasAttribute('data-public-get')) return;
        const href = link.getAttribute('href');
        if (!href || href.startsWith('#') || href.startsWith('mailto:') ||
            href.startsWith('tel:') || href.startsWith('javascript:') ||
            href.startsWith('blob:')) return;

        const destination = new URL(link.href, window.location.href);
        if (destination.origin !== window.location.origin || isReadOnly(destination.href)) return;

        event.preventDefault();
        postTo(destination.href, {}, link.target || '');
    });

    window.awgvaPost = navigate;
})();