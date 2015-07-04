window.setTimeout(function() {
    if (!window.sogoumse_readystate_listener_inject) {
        var b = function() {
            var b = !1;
            if ("interactive" == document.readyState || "complete" == document.readyState) {
                var b = !0,
                a = document.getElementById("sogoumse_readystate_message_iframe");
                void 0 == a && (a = document.createElement("iframe"), a.id = "sogoumse_readystate_message_iframe", document.body.appendChild(a));
                "none" != a.style.display && (a.style.display = "none");
                a.src = window.location.origin + "/s.o.g.o.u.m.s.e/___sogoumse_readystate_msg_location_fragment___"
            }
            return b
        };
        b() || document.addEventListener("readystatechange", b, !1);
        window.sogoumse_readystate_listener_inject = !0
    }
},
0);