"use strict";
/* ============================================================
   ORÁCULO DO CARTUCHO — baralho completo (78 cartas)
   Ordem dos Arcanos Maiores: Marselha (VIII = A Força, XI = A Justiça),
   batendo com as artes já pintadas (VIII - A Força = 0009.jpg,
   X - A Roda da Fortuna = 0007.jpg).
   Artes por carta: cartas/NNNN.jpg (0001–0078) — cada nova pintura
   entra no acervo sem tocar no código.
   Formato das menores: "leitura no erguido | leitura na invertida".
   ============================================================ */
const ARCOS_MAIOR = [
 { n: 0,  nome: "O Louco",            texto: "Partida livre, confiança, salto no desconhecido.",               inv: "Imprudência, fuga da realidade, passo sem olhar." },
 { n: 1,  nome: "O Mago",             texto: "Vontade que age: recursos e talento à mesa.",                    inv: "Manipulação, talento desperdiçado, truque vazio." },
 { n: 2,  nome: "A Sacerdotisa",      texto: "Intuição, mistério, o saber que não se fala.",                   inv: "Segredos afogados, silêncio que adoece, intuição ignorada." },
 { n: 3,  nome: "A Imperatriz",       texto: "Fertilidade, cuidado, tudo que floresce com tempo.",             inv: "Excesso de zelo, sufoco, criação estagnada." },
 { n: 4,  nome: "O Imperador",        texto: "Estrutura, autoridade serena, ordem que protege.",               inv: "Rigidez, controle exagerado, tirania doméstica." },
 { n: 5,  nome: "O Hierofante",       texto: "Tradição, ensino, rituais que unem o grupo.",                    inv: "Dogmatismo, convenção vazia, doutrina que prende." },
 { n: 6,  nome: "Os Amantes",         texto: "Escolha do coração, união, valores alinhados.",                  inv: "Valores desalinhados, hesitação, apego mal escolhido." },
 { n: 7,  nome: "O Carro",            texto: "Avanço disciplinado, direção firme, vitória por constância.",    inv: "Forças esfaceladas, freio sem mãos, agressividade." },
 { n: 8,  nome: "A Força",            texto: "Coragem branda, domar a fera com calma e afeto.",                inv: "Dúvida, explosão contida, submissão ao medo." },
 { n: 9,  nome: "O Eremita",          texto: "Recolhimento fértil, lâmpada própria, saber interior.",          inv: "Isolamento demais, frieza, luz que não se compartilha." },
 { n: 10, nome: "A Roda da Fortuna",  texto: "Ciclos que giram, sorte que muda de lado.",                      inv: "Giro negado, resistir à roda, fase de azar." },
 { n: 11, nome: "A Justiça",          texto: "Balança honesta, causa e efeito sem nó.",                        inv: "Balança torta, viés, conta que não fecha." },
 { n: 12, nome: "O Pendurado",        texto: "Pausa vista de cabeça para baixo: recomeço em silêncio.",        inv: "Paralisia inútil, martírio à toa, sacrifício sem sentido." },
 { n: 13, nome: "A Morte",            texto: "Fim que abre caminho: travessia inevitável.",                    inv: "Pendência que apodrece, fim negado, passagem travada." },
 { n: 14, nome: "A Temperança",       texto: "Alquimia do meio-termo, mistura paciente.",                      inv: "Desequilíbrio, mistura apressada, excesso." },
 { n: 15, nome: "O Diabo",            texto: "Amarra que se escolhe: desejo, contrato, sombra assumida.",      inv: "Corda cortada, desvencilhar-se, sombra reconhecida." },
 { n: 16, nome: "A Torre",            texto: "Trovoada que derruba o falso: revelação abrupta.",               inv: "Medo de ruir, queda adiada, colapso em câmera lenta." },
 { n: 17, nome: "A Estrela",          texto: "Esperança após a tempestade, guia serena, cura.",                inv: "Fé minguada, estrela escondida, desânimo." },
 { n: 18, nome: "A Lua",              texto: "Sonho, intuição nebulosa, caminho entre ilusões.",               inv: "Névoa se dissipando, medo revelado, insônia da alma." },
 { n: 19, nome: "O Sol",              texto: "Claridade plena, vitalidade, sucesso.",                          inv: "Sol encoberto, brilho adiado, otimismo forçado." },
 { n: 20, nome: "O Julgamento",       texto: "Trombeta do chamado: renascimento, balanço honesto.",            inv: "Julgamento cruel, chamado ignorado, dúvida que prende." },
 { n: 21, nome: "O Mundo",            texto: "Ciclo completo, integração, chegada e passaporte.",              inv: "Arcada incompleta, etapa aberta, mundo pendente." }
];

const NAIPES = {
 "Paus": {
   elemento: "Fogo — ação, criatividade e impulso",
   cartas: {
    "Ás":        "Faísca de começo: o galho verde aponta a direção | Fogo sem fornalha, impulso travado",
    "Dois":      "Planejar o mundo inteiro: visão no mapa antes do passo | Mapa rasgado, ambição cega",
    "Três":      "Navio chegando: expansão e olhar no horizonte | Horizonte adiado, barco em reparo",
    "Quatro":    "Festa sob a pérgula: celebração e alicerce firme | Pérgula vazia, festa adiada, base trêmula",
    "Cinco":     "Saramelo de ideias: disputa que afia e cansa | Disputa esvaziada, rival que vira aliado",
    "Seis":      "Louros na vara: reconhecimento pelo feito | Louro murcho, elogio escasso",
    "Sete":      "Vigília no alto da ladeira: defesa da posição conquistada | Defesa cansada, vigília ociosa",
    "Oito":      "Setas em pleno ar: ritmo acelerado, notícia a caminho | Setas travadas, andamento emperrado",
    "Nove":      "Vigia ferido mas de plantão: resiliência sob guarda | Guarda baixada, ferida lembrada demais",
    "Dez":       "Feixe pesado nos ombros: carga grande, meta quase ao alcance | Carga solta, fardo que se compartilha",
    "Valete":    "Mensageiro ardente: entusiasmo que anuncia | Faísca sem lenha, pressa sem plano",
    "Cavaleiro": "Aventura em passo firme: puro ímpeto guiado | Ímpeto sem rédeas, voar para dentro do muro",
    "Rainha":    "Braseiro caseiro: magnetismo, calor e domínio amável | Calor sufocante, braseiro apressado",
    "Rei":       "Ferreiro do próprio destino: liderança e visão de fogo | Usurpação, fogo consumindo o dono"
   }
 },
 "Copas": {
   elemento: "Água — emoção, vínculo e intuição",
   cartas: {
    "Ás":        "Taça transbordante: sentimento novo, coração aberto | Taça rachada, sentimento entupido",
    "Dois":      "Par de taças: encontro, troca, parceria de peito | Encontro desequilibrado, troca torta",
    "Três":      "Dança de taças: amizade, festa da comunhão | Terceiro incômodo, festa com alma alheia",
    "Quatro":    "Taça oferecida e desdenhada: apatia que adia o presente | Presente aceito, despertar",
    "Cinco":     "Taças tombadas: perda que vira lente, não covil | Lente vesga, óculos que só veem o vazio",
    "Seis":      "Dádiva entre crianças: memória doce, nostalgia boa | Passado que prende, memória açucarada demais",
    "Sete":      "Sete taças nas nuvens: desejos que precisam de chão | Sonho pisado, nuvem que caiu em chuva boa",
    "Oito":      "Retirada discreta: deixar as taças cheias para buscar mais | Fuga do vínculo, abandono prematuro",
    "Nove":      "Taça do desejo: emoção realizada, o prato cheio | Prato cheio vazio: excesso que mata a alegria",
    "Dez":       "Arco-íris de taças no céu: família, contentamento pleno | Arco-íris cindido, casa dividida",
    "Valete":    "Mensageiro sentimental: convite, recadinho do coração | Recado torto, romantismo apressado",
    "Cavaleiro": "Cavaleiro da taça: romantismo com arreios | Poema sem freio, charme que afoga",
    "Rainha":    "Taça mansa e profunda: empatia que escuta e cura | Empatia que absorve demais, taça invertida",
    "Rei":       "Cálice equilibrado: maturidade emocional que governa | Calma calculada, coração trancado"
   }
 },
 "Espadas": {
   elemento: "Ar — mente, verdade e conflito",
   cartas: {
    "Ás":        "Lâmina limpa: verdade que corta o nó mentiroso | Lâmina torta, briga de verdades a meias",
    "Dois":      "Venda sobre pedra: escolha às cegas, pacto silencioso | Pacto revisto, venda num capote",
    "Três":      "Coração atravessado: dor que esclarece | Dor lustral negada, sabre guardado por covardia",
    "Quatro":    "Descanso do cavaleiro de pedra: pausa para recuperar | Pausa que vira marasmo, repouso sem hora de vir",
    "Cinco":     "Espólios no vento: vitória com perdas e clientela magoada | Armistício, rendição que poupa",
    "Seis":      "Barca da travessia: sair da tormenta com poucos fardos | Barco a remo sem mar, fuga de água fria",
    "Sete":      "Subterfúgio com espadas: estratégia sigilosa | Estratégia revelada, engano desmontado",
    "Oito":      "Vendado entre lâminas: prisão que a própria mente arma | Nó cortado, caminho de saída enxergado",
    "Nove":      "Insônia das espadas: angústia que cresce na cama | Manhã: o monstro era pequeno, alívio",
    "Dez":       "Fim da lâmina nas costas: derrota limpa, cais definitivo | Reerguer-se aos poucos, faca removida",
    "Valete":    "Mensageiro afiado: notícia que divide | Lâmina bisbilhote, espionagem de mentirinha",
    "Cavaleiro": "Vento da mudança: decisão rápida, ataque e defesa | Atropelo mental, guerra sem tática",
    "Rainha":    "Percepção cortante e honesta: sabedoria sem meias-verdades | Amargura analítica, saber que fere",
    "Rei":       "Juiz de espada: autoridade da razão translúcida | Tirania lógica, razão sem coração"
   }
 },
 "Ouros": {
   elemento: "Terra — matéria, trabalho e corpo",
   cartas: {
    "Ás":        "Moeda brotando: semente material, salário, chance concreta | Semente guardada demais, broto perdido",
    "Dois":      "Dança das moedas: malabarismo entre dois mundos | Malabarismo perdido, gente pulada fora",
    "Três":      "Oficina sob o arco: obra bem feita, terceiro reconhecido | Obra mal avaliada, arco com defeito",
    "Quatro":    "Moedas abraçadas: segurança que já roça ganância | Clã apertado demais, mão que abre",
    "Cinco":     "Dois peregrinos à porta: escassez e ajuda que não se pede | Ajuda aceita, inverno transposto",
    "Seis":      "Balança das moedas: generosidade e troca justa | Caridade com juros, balança manota",
    "Sete":      "Agricultor pensativo: colheita amadurecendo no tempo | Colheita adiada por preguiça da terra",
    "Oito":      "Ourives repetindo o traço: dedicação que lapida | Traço torto, lapidez perdida",
    "Nove":      "Jardim murado: abundância conquistada e vigilante | Confisco na porta, jardim infestado",
    "Dez":       "Casa em rua com moedas: riqueza que vira legado | Legado contestado, patrimônio dividido à toa",
    "Valete":    "Mensageiro da matéria: proposta, estágio, primeiro salário | Proposta rasa, estágio sem chão",
    "Cavaleiro": "Cavaleiro paciente: método que atravessa serra | Rotina engessada, passo lento demais",
    "Rainha":    "Rainha dos hortos: praticidade generosa que nutre | Cuidados que afogam a plantação",
    "Rei":       "Barão do solo: prosperidade mansa e justa | Avidez que minera, tesouro que apodrece de longo"
   }
 }
};

/* Carta do dia: determinística pela data (mesma carta para a mesma data) */
function cartaDoDia(dataIso){
  let h = 0;
  for (const ch of String(dataIso)) h = (h * 31 + ch.charCodeAt(0)) % 1000003;
  return h;
}

/* Monta a lista completa: 22 maiores + 56 menores = 78 */
const ORDEM_MENORES = ["Ás","Dois","Três","Quatro","Cinco","Seis","Sete","Oito","Nove","Dez","Valete","Cavaleiro","Rainha","Rei"];
const BARALHO_TARO = (() => {
  const lista = [];
  ARCOS_MAIOR.forEach(c => lista.push({ tipo: "maior", ...c }));
  let seq = ARCOS_MAIOR.length;
  for (const naipe of Object.keys(NAIPES)) {
    ORDEM_MENORES.forEach((r) => {
      const partes = String(NAIPES[naipe].cartas[r]).split("|");
      lista.push({ tipo: "menor", naipe, rank: r, n: seq,
                   texto: partes[0].trim(), inv: (partes[1] || partes[0]).trim(),
                   elemento: NAIPES[naipe].elemento });
      seq += 1;
    });
  }
  lista.forEach((c, i) => { c.arteId = String(i + 1).padStart(4, "0"); });
  return lista;
})();

/* Artes já pintadas cujo nome de arquivo difere da ordem padrão */
const ARTES_EXTRAS = { "0011": "0007.jpg", "0009": "0009.jpg" };
function arquivoArte(c){
  if (ARTES_EXTRAS[c.arteId]) return "cartas/" + ARTES_EXTRAS[c.arteId];
  return "cartas/" + c.arteId + ".jpg";
}
