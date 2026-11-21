"use strict";
/* ============================================================
   ORÁCULO DO CARTUCHO — lógica do visualizador (offline)
   ============================================================ */
(function(){
  const elCarta = document.getElementById("carta");
  const elNumTop = document.getElementById("numTop");
  const elNomeTop = document.getElementById("nomeTop");
  const elNumRod = document.getElementById("numRod");
  const elTtl = document.getElementById("ttl");
  const elTxt = document.getElementById("txt");
  const elInv = document.getElementById("inv");
  const elNaipe = document.getElementById("naipe");
  const elAcervo = document.getElementById("acervo");

  let atual = null, invertida = false;

  function rotuloDe(c){
    if (c.tipo === "maior"){
      const romanos = ["0","I","II","III","IV","V","VI","VII","VIII","IX","X","XI",
                       "XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX","XXI"];
      return { num: romanos[c.n], nome: c.nome };
    }
    const simbolo = {Paus: "🪓", Copas: "🍷", Espadas: "⚔️", Ouros: "🪙"}[c.naipe];
    return { num: c.naipe + (c.rank === "Ás" ? " • Ás" : " • " + c.rank), nome: simbolo + " " + c.rank + " de " + c.naipe };
  }

  function pintar(c, invert){
    atual = c; invertida = !!invert;
    const rot = rotuloDe(c);

    elNumTop.textContent = (c.tipo === "maior" ? "ARCANO " : "") + rot.num;
    elNomeTop.textContent = rot.nome;
    elNumRod.textContent = "carta " + c.arteId + " de 0078" + (invertida ? " • invertida" : "");

    elTtl.textContent = (invertida ? c.nome + " (invertida)" : c.nome);
    elTxt.textContent  = invertida ? c.inv : c.texto;
    elInv.textContent  = invertida ? "(erguida: " + c.texto + ")" : "(invertida: " + c.inv + ")";
    elNaipe.textContent = c.tipo === "maior"
      ? "Grande Mistério — o caminho inteiro"
      : c.elemento;

    elCarta.classList.toggle("invertida", invertida);
    elCarta.classList.remove("img");

    /* arte do acervo, se existir; fallback: moldura violeta com numeral */
    const img = new Image();
    img.onload = () => {
      const velha = elCarta.querySelector(".arte");
      if (velha) velha.remove();
      const im = document.createElement("img");
      im.className = "arte";
      im.src = img.src;
      im.alt = rot.nome;
      elCarta.appendChild(im);
      elCarta.classList.add("img");
    };
    img.onerror = () => {
      const velha = elCarta.querySelector(".arte");
      if (velha) velha.remove();
    };
    img.src = arquivoArte(c) + "?v=" + Date.now();
  }

  function contarArtes(){
    /* conta quantas artes existem no acervo local (0001–0078) */
    let existe = 0, verificando = 0, total = BARALHO_TARO.length;
    BARALHO_TARO.forEach(c => {
      verificando++;
      const img = new Image();
      img.onload = () => { existe++; elAcervo.textContent = povoado(existe, total); };
      img.onerror = () => { elAcervo.textContent = povoado(existe, total); };
      img.src = arquivoArte(c) + "?sondar";
    });
  }
  function povoado(n, total){
    return "🎨 Acervo pintado: " + n + " de " + total +
           " cartas — faltam " + (total - n) +
           " pinturas (quest M-030 do Quadro de Missões)";
  }

  document.getElementById("btnTirar").onclick = () => {
    const c = BARALHO_TARO[Math.floor(Math.random() * BARALHO_TARO.length)];
    pintar(c, Math.random() < 0.5);
  };

  document.getElementById("btnInverter").onclick = () => {
    if (atual) pintar(atual, !invertida);
  };

  document.getElementById("btnDia").onclick = () => {
    const hoje = new Date();
    const iso = hoje.getFullYear() + "-" +
                String(hoje.getMonth() + 1).padStart(2, "0") + "-" +
                String(hoje.getDate()).padStart(2, "0");
    const idx = cartaDoDia(iso) % BARALHO_TARO.length;
    pintar(BARALHO_TARO[idx], (cartaDoDia(iso + "v") & 1) === 1);
  };

  contarArtes();
})();
