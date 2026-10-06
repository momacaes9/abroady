/* ==========================================================================
   ABROADY — data.js
   All the CONTENT of the app lives here, separate from the logic.
   Every text that changes with the language is an object like:
       { en: "English", pt: "Português", es: "Español" }
   The helper tr() in script.js picks the right one.
   👉 To add a club, task, peer, event or review: copy an item and edit it.
   ========================================================================== */

/* ---------- Orientation checklist ---------- */
const CHECKLIST = [
  {
    icon: "🛂",
    title: { en: "Immigration & Visa", pt: "Imigração e visto", es: "Inmigración y visa" },
    when: { en: "Before arrival · Week 1", pt: "Antes de chegar · Semana 1", es: "Antes de llegar · Semana 1" },
    tasks: [
      { id: "passport",
        label: { en: "Passport valid 6+ months", pt: "Passaporte válido por 6+ meses", es: "Pasaporte válido por 6+ meses" },
        hint: { en: "Renew early through your home country's consulate.", pt: "Renove com antecedência no consulado do seu país.", es: "Renuévalo con tiempo en el consulado de tu país." } },
      { id: "i20",
        label: { en: "Signed I-20 / DS-2019 in your carry-on", pt: "I-20 / DS-2019 assinado na bagagem de mão", es: "I-20 / DS-2019 firmado en tu equipaje de mano" },
        hint: { en: "Never pack immigration documents in checked luggage.", pt: "Nunca despache documentos de imigração na mala.", es: "Nunca factures documentos migratorios." } },
      { id: "i94",
        label: { en: "Download your I-94 arrival record", pt: "Baixe seu registro de entrada I-94", es: "Descarga tu registro de entrada I-94" },
        hint: { en: "Free on the U.S. CBP I-94 website after you land.", pt: "Grátis no site I-94 do CBP depois que você chegar.", es: "Gratis en el sitio I-94 de CBP después de aterrizar." } },
      { id: "isss",
        label: { en: "Complete the international student check-in", pt: "Faça o check-in de estudante internacional", es: "Completa el check-in de estudiante internacional" },
        hint: { en: "Upload passport, visa and I-94 to activate your SEVIS record.", pt: "Envie passaporte, visto e I-94 para ativar seu registro no SEVIS.", es: "Sube pasaporte, visa e I-94 para activar tu registro SEVIS." } },
    ],
  },
  {
    icon: "📚",
    title: { en: "Course Registration for Non-Citizens", pt: "Matrícula para não cidadãos", es: "Inscripción para no ciudadanos" },
    when: { en: "Weeks 1–2", pt: "Semanas 1–2", es: "Semanas 1–2" },
    tasks: [
      { id: "fulltime",
        label: { en: "Register for 12+ credit hours", pt: "Matricule-se em 12+ créditos", es: "Inscríbete en 12+ créditos" },
        hint: { en: "F-1 undergrads must stay full-time every fall & spring.", pt: "Alunos F-1 precisam ser full-time todo outono e primavera.", es: "Los estudiantes F-1 deben ser de tiempo completo cada otoño y primavera." } },
      { id: "online",
        label: { en: "Max. one online course toward full-time", pt: "No máximo uma matéria online conta para o full-time", es: "Máximo un curso en línea cuenta para tiempo completo" },
        hint: { en: "Only one online class can count toward your F-1 minimum.", pt: "Só uma aula online conta para o mínimo do F-1.", es: "Solo una clase en línea cuenta para tu mínimo F-1." } },
      { id: "advisor",
        label: { en: "Meet your academic advisor", pt: "Converse com seu orientador acadêmico", es: "Reúnete con tu asesor académico" },
        hint: { en: "Ask about AP / IB / A-level credit from your home country.", pt: "Pergunte sobre créditos de AP / IB / A-level do seu país.", es: "Pregunta por créditos de AP / IB / A-level de tu país." } },
      { id: "transfer",
        label: { en: "Plan Gen Eds that transfer from abroad", pt: "Planeje Gen Eds que valem no intercâmbio", es: "Planea Gen Eds que se convaliden en el extranjero" },
        hint: { en: "Leave room in year 2 for courses you can take at UNSW.", pt: "Deixe espaço no 2º ano para matérias que você pode fazer na UNSW.", es: "Deja espacio en 2º año para cursos que puedas tomar en UNSW." } },
    ],
  },
  {
    icon: "💳",
    title: { en: "Money, Health & Daily Life", pt: "Dinheiro, saúde e dia a dia", es: "Dinero, salud y vida diaria" },
    when: { en: "First month", pt: "Primeiro mês", es: "Primer mes" },
    tasks: [
      { id: "bank",
        label: { en: "Open a U.S. bank account", pt: "Abra uma conta bancária nos EUA", es: "Abre una cuenta bancaria en EE. UU." },
        hint: { en: "Bring passport, I-20 and your enrollment letter.", pt: "Leve passaporte, I-20 e comprovante de matrícula.", es: "Lleva pasaporte, I-20 y tu carta de matrícula." } },
      { id: "insurance",
        label: { en: "Confirm student health insurance", pt: "Confirme o seguro-saúde estudantil", es: "Confirma tu seguro médico estudiantil" },
        hint: { en: "Check whether your home plan qualifies for a waiver.", pt: "Veja se o seu plano do país de origem permite dispensa.", es: "Revisa si tu plan de origen permite una exención." } },
      { id: "job",
        label: { en: "Check on-campus job rules", pt: "Entenda as regras de trabalho no campus", es: "Revisa las reglas de trabajo en el campus" },
        hint: { en: "F-1 students can usually work up to 20 hrs/week on campus during term.", pt: "Alunos F-1 geralmente podem trabalhar até 20 h/semana no campus durante o semestre.", es: "Los estudiantes F-1 suelen poder trabajar hasta 20 h/semana en el campus durante el semestre." } },
      { id: "phone",
        label: { en: "Get a U.S. phone number", pt: "Tenha um número de celular americano", es: "Consigue un número de teléfono de EE. UU." },
        hint: { en: "Needed for 2-factor login and campus safety alerts.", pt: "Necessário para login em 2 etapas e alertas de segurança.", es: "Necesario para el inicio de sesión en 2 pasos y alertas de seguridad." } },
    ],
  },
  {
    icon: "🦘",
    title: { en: "Study Abroad Early — Sydney Track", pt: "Intercâmbio cedo — trilha Sydney", es: "Intercambio temprano — ruta Sídney" },
    when: { en: "Year 1 · Spring", pt: "1º ano · Primavera", es: "1er año · Primavera" },
    tasks: [
      { id: "info",
        label: { en: "Attend a Study Abroad 101 session", pt: "Participe de uma sessão Study Abroad 101", es: "Asiste a una sesión Study Abroad 101" },
        hint: { en: "Learn which exchanges accept second-year students.", pt: "Descubra quais intercâmbios aceitam alunos do 2º ano.", es: "Descubre qué intercambios aceptan estudiantes de 2º año." } },
      { id: "unsw",
        label: { en: "Meet an advisor about the UNSW exchange", pt: "Converse com um orientador sobre a UNSW", es: "Habla con un asesor sobre el intercambio en UNSW" },
        hint: { en: "Bring a draft list of courses you'd like credit for.", pt: "Leve uma lista das matérias que quer validar.", es: "Lleva una lista de los cursos que quieres convalidar." } },
      { id: "gpa",
        label: { en: "Note the GPA minimum & application deadline", pt: "Anote o GPA mínimo e o prazo de inscrição", es: "Anota el GPA mínimo y la fecha límite" },
        hint: { en: "Add the deadline to your calendar now.", pt: "Coloque o prazo na sua agenda agora.", es: "Agrega la fecha límite a tu calendario ahora." } },
      { id: "status",
        label: { en: "Ask how to keep F-1 status while abroad", pt: "Pergunte como manter o status F-1 no exterior", es: "Pregunta cómo mantener tu estatus F-1 en el extranjero" },
        hint: { en: "You'll need a travel signature on your I-20 to re-enter the U.S.", pt: "Você precisa de uma assinatura de viagem no I-20 para voltar aos EUA.", es: "Necesitarás una firma de viaje en tu I-20 para volver a EE. UU." } },
      { id: "visa500",
        label: { en: "Research the Australian Student visa (subclass 500)", pt: "Pesquise o visto de estudante australiano (subclasse 500)", es: "Investiga la visa de estudiante australiana (subclase 500)" },
        hint: { en: "Includes Overseas Student Health Cover (OSHC).", pt: "Inclui o seguro-saúde OSHC.", es: "Incluye el seguro médico OSHC." } },
    ],
  },
];

/* ---------- Club directory (demo) ----------
   category must be one of: Global, Cultural, Academic, Career, Social */
const CLUBS = [
  { name: "Sydney Spring Exchange Group", emoji: "🦘", category: "Global", members: 12, freshman: true, intl: true, tags: ["Sydney", "UNSW", "Exchange"],
    meets: { en: "Biweekly · Thu 7pm", pt: "Quinzenal · Qui 19h", es: "Quincenal · Jue 7pm" },
    desc: { en: "Underclassmen planning a spring semester at UNSW Sydney. Course mapping, housing and visa tips.", pt: "Alunos do 1º e 2º ano planejando um semestre na UNSW Sydney. Matérias, moradia e dicas de visto.", es: "Estudiantes de primeros años que planean un semestre en UNSW Sídney. Cursos, vivienda y consejos de visa." } },
  { name: "Global Explorers Society", emoji: "🧭", category: "Global", members: 140, freshman: true, intl: true, tags: ["Study abroad", "Mentoring"],
    meets: { en: "Weekly · Tue 6pm", pt: "Semanal · Ter 18h", es: "Semanal · Mar 6pm" },
    desc: { en: "Returning study-abroad students mentor first-years on choosing a program and applying early.", pt: "Alunos que voltaram do intercâmbio orientam calouros a escolher um programa e se inscrever cedo.", es: "Estudiantes que regresaron del extranjero guían a los de primer año para elegir programa y postular temprano." } },
  { name: "Study Abroad Peer Ambassadors", emoji: "✈️", category: "Global", members: 45, freshman: true, intl: true, tags: ["Q&A", "Advice"],
    meets: { en: "Drop-in hours · Mon–Wed", pt: "Plantão · Seg–Qua", es: "Horario abierto · Lun–Mié" },
    desc: { en: "Ask students who've already been abroad anything — budgets, credits, homesickness.", pt: "Pergunte qualquer coisa a quem já fez intercâmbio: orçamento, créditos, saudade de casa.", es: "Pregunta lo que quieras a quienes ya estudiaron afuera: presupuesto, créditos, nostalgia." } },
  { name: "International Student Association", emoji: "🌐", category: "Cultural", members: 320, freshman: true, intl: true, tags: ["Community", "Events"],
    meets: { en: "Monthly mixers", pt: "Encontros mensais", es: "Encuentros mensuales" },
    desc: { en: "The home base for international students: cultural nights, airport pickups and holiday dinners.", pt: "A casa dos estudantes internacionais: noites culturais, buscas no aeroporto e jantares de feriado.", es: "El hogar de los estudiantes internacionales: noches culturales, recogidas en el aeropuerto y cenas festivas." } },
  { name: "Brazilian Student Association", emoji: "🇧🇷", category: "Cultural", members: 60, freshman: true, intl: true, tags: ["Brazil", "Portuguese"],
    meets: { en: "Biweekly · Fri 5pm", pt: "Quinzenal · Sex 17h", es: "Quincenal · Vie 5pm" },
    desc: { en: "Futebol, feijoada and a support network for Brazilian and Portuguese-speaking students.", pt: "Futebol, feijoada e uma rede de apoio para brasileiros e falantes de português.", es: "Fútbol, feijoada y una red de apoyo para brasileños y hablantes de portugués." } },
  { name: "Latin American Student Union", emoji: "🌎", category: "Cultural", members: 180, freshman: true, intl: true, tags: ["Latin America", "Spanish"],
    meets: { en: "Weekly · Wed 7pm", pt: "Semanal · Qua 19h", es: "Semanal · Mié 7pm" },
    desc: { en: "Celebrating Latin American cultures through dance, food, film and advocacy.", pt: "Celebrando as culturas latino-americanas com dança, comida, cinema e ativismo.", es: "Celebrando las culturas latinoamericanas con baile, comida, cine y activismo." } },
  { name: "Asian Students Collective", emoji: "🏮", category: "Cultural", members: 210, freshman: true, intl: true, tags: ["Big-sib program", "Culture"],
    meets: { en: "Weekly · Thu 6pm", pt: "Semanal · Qui 18h", es: "Semanal · Jue 6pm" },
    desc: { en: "Cultural showcases, a big-sib program for freshmen, and Lunar New Year celebrations.", pt: "Mostras culturais, programa de padrinhos para calouros e festa do Ano-Novo Lunar.", es: "Muestras culturales, programa de padrinos para nuevos y celebración del Año Nuevo Lunar." } },
  { name: "Conversation Partners", emoji: "🗣️", category: "Social", members: 95, freshman: true, intl: true, tags: ["Language exchange", "English"],
    meets: { en: "Flexible · 1:1 pairs", pt: "Flexível · duplas 1:1", es: "Flexible · parejas 1:1" },
    desc: { en: "Get paired with a domestic student for weekly language & culture exchange over coffee.", pt: "Forme dupla com um aluno americano para trocar idioma e cultura toda semana, com café.", es: "Te emparejan con un estudiante local para intercambiar idioma y cultura cada semana con un café." } },
  { name: "First-Year Friday Coffee", emoji: "☕", category: "Social", members: 75, freshman: true, intl: true, tags: ["Friends", "Low-key"],
    meets: { en: "Fridays · 10am", pt: "Sextas · 10h", es: "Viernes · 10am" },
    desc: { en: "Low-pressure weekly meetup for freshmen to make friends outside their dorm.", pt: "Encontro semanal tranquilo para calouros fazerem amigos fora do dormitório.", es: "Encuentro semanal relajado para hacer amigos fuera de tu residencia." } },
  { name: "Outdoors & Hiking Club", emoji: "🥾", category: "Social", members: 150, freshman: true, intl: false, tags: ["Outdoors", "Weekend"],
    meets: { en: "Weekend trips", pt: "Viagens de fim de semana", es: "Salidas de fin de semana" },
    desc: { en: "Day hikes, camping and climbing trips — gear provided for beginners.", pt: "Trilhas, camping e escalada, com equipamento para iniciantes.", es: "Caminatas, camping y escalada, con equipo para principiantes." } },
  { name: "Data Science Club", emoji: "📊", category: "Academic", members: 130, freshman: true, intl: true, tags: ["Coding", "Python", "Data"],
    meets: { en: "Weekly · Mon 7pm", pt: "Semanal · Seg 19h", es: "Semanal · Lun 7pm" },
    desc: { en: "Python & SQL workshops, Kaggle teams and project nights. No experience needed.", pt: "Oficinas de Python e SQL, times de Kaggle e noites de projeto. Sem experiência necessária.", es: "Talleres de Python y SQL, equipos de Kaggle y noches de proyectos. Sin experiencia previa." } },
  { name: "Economics Society", emoji: "📈", category: "Academic", members: 110, freshman: true, intl: true, tags: ["Economics", "Finance"],
    meets: { en: "Biweekly · Tue 7pm", pt: "Quinzenal · Ter 19h", es: "Quincenal · Mar 7pm" },
    desc: { en: "Speaker events, case competitions and markets discussions for econ-curious students.", pt: "Palestras, competições de cases e conversas sobre mercado para quem curte economia.", es: "Charlas, competencias de casos y debates de mercados para curiosos de la economía." } },
  { name: "Model United Nations", emoji: "🏛️", category: "Academic", members: 90, freshman: false, intl: true, tags: ["Debate", "Global affairs"],
    meets: { en: "Weekly · Wed 6pm", pt: "Semanal · Qua 18h", es: "Semanal · Mié 6pm" },
    desc: { en: "Compete at conferences around the country — international perspectives are a superpower here.", pt: "Competições em conferências pelo país, onde a visão internacional é um superpoder.", es: "Compite en conferencias por todo el país, donde la mirada internacional es un superpoder." } },
  { name: "Women in Business", emoji: "💼", category: "Career", members: 170, freshman: true, intl: true, tags: ["Mentorship", "Recruiting"],
    meets: { en: "Biweekly · Thu 6pm", pt: "Quinzenal · Qui 18h", es: "Quincenal · Jue 6pm" },
    desc: { en: "Mentorship, resume reviews and recruiting prep with alumni across industries.", pt: "Mentoria, revisão de currículo e preparação para processos seletivos com ex-alunos.", es: "Mentoría, revisión de CV y preparación para procesos de selección con egresadas." } },
  { name: "Global Careers Network", emoji: "🌍", category: "Career", members: 85, freshman: true, intl: true, tags: ["OPT", "Internships"],
    meets: { en: "Monthly panels", pt: "Painéis mensais", es: "Paneles mensuales" },
    desc: { en: "Navigate CPT/OPT, international internships and careers that use your global experience.", pt: "Entenda CPT/OPT, estágios internacionais e carreiras que valorizam sua experiência global.", es: "Entiende CPT/OPT, prácticas internacionales y carreras que valoran tu experiencia global." } },
  { name: "Student Consulting Group", emoji: "🧠", category: "Career", members: 60, freshman: false, intl: true, tags: ["Consulting", "Projects"],
    meets: { en: "Application-based", pt: "Por processo seletivo", es: "Con postulación" },
    desc: { en: "Pro-bono consulting projects for local nonprofits and startups. Recruits each fall.", pt: "Projetos de consultoria gratuita para ONGs e startups locais. Seleção todo outono.", es: "Proyectos de consultoría gratuita para ONG y startups locales. Recluta cada otoño." } },
];

/* ---------- Peer match (demo people) ---------- */
const PEERS = [
  { id: "lm", name: "Lucas Martins", initials: "LM", hue: 200, year: "1", from: "🇧🇷 Brazil", destination: "UNSW Sydney", term: "Spring 2028", score: 94,
    major: { en: "Business", pt: "Administração", es: "Negocios" },
    interests: { en: ["Surfing", "Finance", "Football"], pt: ["Surfe", "Finanças", "Futebol"], es: ["Surf", "Finanzas", "Fútbol"] },
    opener: { en: "Hi! I saw you're also aiming for UNSW in Spring 2028 🙌", pt: "Oi! Vi que você também quer ir pra UNSW na primavera de 2028 🙌", es: "¡Hola! Vi que tú también apuntas a UNSW en primavera 2028 🙌" },
    replies: {
      en: ["Have you met with a study abroad advisor yet? I'm booking for next week.", "Let's map our Gen Eds together so we both stay on track!", "Down to grab coffee after class Thursday?"],
      pt: ["Você já falou com um orientador de intercâmbio? Vou marcar pra semana que vem.", "Bora montar nossas Gen Eds juntos pra ninguém se atrasar!", "Topa um café depois da aula na quinta?"],
      es: ["¿Ya hablaste con un asesor de intercambio? Voy a agendar para la próxima semana.", "¡Armemos juntos nuestras Gen Eds para no atrasarnos!", "¿Un café después de clase el jueves?"] } },
  { id: "ak", name: "Aisha Khan", initials: "AK", hue: 330, year: "1", from: "🇵🇰 Pakistan", destination: "UNSW Sydney", term: "Spring 2028", score: 89,
    major: { en: "Public Health", pt: "Saúde Pública", es: "Salud Pública" },
    interests: { en: ["Volunteering", "Photography"], pt: ["Voluntariado", "Fotografia"], es: ["Voluntariado", "Fotografía"] },
    opener: { en: "Hi! Are you an F-1 student too? Trying to figure out the travel signature thing 😅", pt: "Oi! Você também é F-1? Tô tentando entender a tal assinatura de viagem 😅", es: "¡Hola! ¿También eres F-1? Intento entender lo de la firma de viaje 😅" },
    replies: {
      en: ["They said to request it about 2 weeks before leaving.", "We should start a shared doc of visa steps for the group!", "Also — have you looked at UNSW housing options?"],
      pt: ["Disseram pra pedir umas 2 semanas antes de viajar.", "A gente devia fazer um doc compartilhado com os passos do visto pro grupo!", "E aí, já olhou as opções de moradia da UNSW?"],
      es: ["Dijeron que la pidamos unas 2 semanas antes de viajar.", "¡Hagamos un documento compartido con los pasos de visa para el grupo!", "Por cierto, ¿ya viste las opciones de vivienda de UNSW?"] } },
  { id: "do", name: "Daniel Okafor", initials: "DO", hue: 150, year: "2", from: "🇳🇬 Nigeria", destination: "UNSW Sydney", term: "Spring 2028", score: 86,
    major: { en: "Computer Science", pt: "Ciência da Computação", es: "Ciencias de la Computación" },
    interests: { en: ["Hackathons", "Basketball"], pt: ["Hackathons", "Basquete"], es: ["Hackatones", "Básquet"] },
    opener: { en: "Hey! UNSW has a great CS program — which courses are you hoping to take?", pt: "E aí! A UNSW tem um ótimo curso de computação. Quais matérias você quer fazer?", es: "¡Hola! UNSW tiene un gran programa de computación. ¿Qué cursos quieres tomar?" },
    replies: {
      en: ["I'm looking at their data science electives.", "Nice, we could be in the same classes!", "I'll add you to the Sydney group chat."],
      pt: ["Tô de olho nas optativas de ciência de dados.", "Massa, podemos cair na mesma turma!", "Vou te adicionar no grupo de Sydney."],
      es: ["Estoy mirando sus optativas de ciencia de datos.", "¡Genial, podríamos estar en las mismas clases!", "Te agrego al chat del grupo de Sídney."] } },
  { id: "mc", name: "Mei Chen", initials: "MC", hue: 20, year: "1", from: "🇨🇳 China", destination: "UNSW Sydney", term: "Spring 2028", score: 91,
    major: { en: "Economics", pt: "Economia", es: "Economía" },
    interests: { en: ["Markets", "Piano", "Hiking"], pt: ["Mercados", "Piano", "Trilhas"], es: ["Mercados", "Piano", "Senderismo"] },
    opener: { en: "Fellow econ major heading to Sydney! 👋", pt: "Outra pessoa de economia indo pra Sydney! 👋", es: "¡Otra persona de economía rumbo a Sídney! 👋" },
    replies: {
      en: ["Did you check which econ courses transfer back?", "I heard UNSW has an econ society we could join.", "Let's compare our 4-year plans this weekend."],
      pt: ["Você já viu quais matérias de economia são validadas aqui?", "Ouvi dizer que a UNSW tem um clube de economia pra gente entrar.", "Bora comparar nossos planos de 4 anos no fim de semana."],
      es: ["¿Ya revisaste qué cursos de economía se convalidan?", "Escuché que UNSW tiene una sociedad de economía para unirnos.", "Comparemos nuestros planes de 4 años este fin de semana."] } },
  { id: "sr", name: "Sofia Rossi", initials: "SR", hue: 270, year: "1", from: "🇮🇹 Italy", destination: "University of Melbourne", term: "Spring 2028", score: 78,
    major: { en: "Global Studies", pt: "Estudos Globais", es: "Estudios Globales" },
    interests: { en: ["Languages", "Film"], pt: ["Idiomas", "Cinema"], es: ["Idiomas", "Cine"] },
    opener: { en: "Ciao! I'm going to Melbourne, but we'll be in Australia at the same time!", pt: "Ciao! Eu vou pra Melbourne, mas vamos estar na Austrália na mesma época!", es: "¡Ciao! Voy a Melbourne, ¡pero estaremos en Australia al mismo tiempo!" },
    replies: {
      en: ["We should plan a weekend trip between Sydney and Melbourne 🚆", "Parli italiano? 😄", "Let's keep in touch!"],
      pt: ["Vamos planejar um fim de semana entre Sydney e Melbourne 🚆", "Parli italiano? 😄", "Vamos manter contato!"],
      es: ["Planeemos un viaje de fin de semana entre Sídney y Melbourne 🚆", "¿Parli italiano? 😄", "¡Sigamos en contacto!"] } },
  { id: "jt", name: "Jake Thompson", initials: "JT", hue: 100, year: "2", from: "🇺🇸 USA", destination: "UNSW Sydney", term: "Fall 2028", score: 72,
    major: { en: "Environmental Science", pt: "Ciências Ambientais", es: "Ciencias Ambientales" },
    interests: { en: ["Ocean", "Sustainability"], pt: ["Oceano", "Sustentabilidade"], es: ["Océano", "Sostenibilidad"] },
    opener: { en: "Hey! I'm a semester after you but happy to share what I learn applying.", pt: "Oi! Vou um semestre depois de você, mas posso contar o que aprender na inscrição.", es: "¡Hola! Voy un semestre después, pero te cuento lo que aprenda al postular." },
    replies: {
      en: ["The application essay asks why this program specifically — start drafting early!", "Happy to review your essay.", "Good luck!"],
      pt: ["A redação pergunta por que esse programa especificamente. Comece cedo!", "Posso revisar sua redação.", "Boa sorte!"],
      es: ["El ensayo pregunta por qué este programa en particular. ¡Empieza temprano!", "Puedo revisar tu ensayo.", "¡Mucha suerte!"] } },
  { id: "pn", name: "Priya Nair", initials: "PN", hue: 45, year: "1", from: "🇮🇳 India", destination: "UNSW Sydney", term: "Fall 2028", score: 83,
    major: { en: "Data Science", pt: "Ciência de Dados", es: "Ciencia de Datos" },
    interests: { en: ["AI", "Dance", "Coding"], pt: ["IA", "Dança", "Programação"], es: ["IA", "Baile", "Programación"] },
    opener: { en: "Hi! Data science + Sydney = we have to be friends 😄", pt: "Oi! Ciência de dados + Sydney = temos que ser amigas 😄", es: "¡Hola! Ciencia de datos + Sídney = tenemos que ser amigas 😄" },
    replies: {
      en: ["Are you in the Data Science Club? I just joined.", "We could build a project together before we go!", "Talk soon!"],
      pt: ["Você tá no Data Science Club? Acabei de entrar.", "A gente podia fazer um projeto juntas antes de ir!", "Até mais!"],
      es: ["¿Estás en el Data Science Club? Me acabo de unir.", "¡Podríamos hacer un proyecto juntas antes de ir!", "¡Hablamos!"] } },
];

/* Group chat for the Sydney cohort (demo) */
const GROUP = {
  id: "group", name: "Sydney Spring Exchange Group", initials: "🌏", hue: 205,
  meta: { en: "12 members · UNSW · Spring 2028", pt: "12 membros · UNSW · Primavera 2028", es: "12 miembros · UNSW · Primavera 2028" },
  seed: {
    en: [["Lucas M.", "Welcome everyone! 🦘 Info session is next Thursday at 5pm."], ["Aisha K.", "Can someone share the course-equivalency spreadsheet?"], ["Mei C.", "Here's my draft list of UNSW econ courses 📎"]],
    pt: [["Lucas M.", "Bem-vindos! 🦘 A sessão informativa é quinta que vem às 17h."], ["Aisha K.", "Alguém pode mandar a planilha de equivalência de matérias?"], ["Mei C.", "Aqui está minha lista de matérias de economia da UNSW 📎"]],
    es: [["Lucas M.", "¡Bienvenidos! 🦘 La sesión informativa es el próximo jueves a las 5pm."], ["Aisha K.", "¿Alguien comparte la hoja de equivalencias de cursos?"], ["Mei C.", "Aquí está mi lista de cursos de economía de UNSW 📎"]],
  },
  replies: {
    en: [["Daniel O.", "Welcome!! 👋"], ["Priya N.", "Who's going to the info session?"], ["Lucas M.", "Let's do a group study-plan session this weekend."]],
    pt: [["Daniel O.", "Bem-vinda!! 👋"], ["Priya N.", "Quem vai na sessão informativa?"], ["Lucas M.", "Bora fazer um encontro pra montar o plano de estudos no fim de semana."]],
    es: [["Daniel O.", "¡¡Bienvenida!! 👋"], ["Priya N.", "¿Quién va a la sesión informativa?"], ["Lucas M.", "Hagamos una sesión de plan de estudios este fin de semana."]],
  },
};

/* ---------- Community channels ----------
   👉 When your Instagram (or other channel) is live, paste the link in "url"
      and change status to "live". */
const CHANNELS = [
  { icon: "📸", name: "Instagram", handle: "@abroady.app", url: "", status: "soon",
    desc: { en: "Daily tips for international and first-year students, cohort shout-outs and event announcements.", pt: "Dicas diárias para estudantes internacionais e calouros, destaques das turmas e avisos de eventos.", es: "Consejos diarios para estudiantes internacionales y de primer año, menciones de cohortes y anuncios de eventos." } },
  { icon: "💬", name: "WhatsApp Community", handle: { en: "One group per destination & term", pt: "Um grupo por destino e semestre", es: "Un grupo por destino y semestre" }, url: "", status: "soon",
    desc: { en: "Cohort group chats like \"Sydney · Spring 2028\", moderated so they stay friendly and useful.", pt: "Grupos por turma, como \"Sydney · Primavera 2028\", moderados para continuarem úteis e acolhedores.", es: "Chats por cohorte como \"Sídney · Primavera 2028\", moderados para que sigan siendo útiles y amables." } },
  { icon: "🎟️", name: { en: "Events", pt: "Eventos", es: "Eventos" }, handle: { en: "On campus & online", pt: "No campus e online", es: "En el campus y en línea" }, url: "", status: "soon",
    desc: { en: "Meetups, info nights and cultural events built for people in their first years on campus.", pt: "Encontros, noites informativas e eventos culturais pensados para quem está nos primeiros anos.", es: "Encuentros, noches informativas y eventos culturales pensados para quienes están en sus primeros años." } },
  { icon: "✉️", name: "Newsletter", handle: { en: "Once a month", pt: "Uma vez por mês", es: "Una vez al mes" }, url: "", status: "soon",
    desc: { en: "Deadlines, new cohorts and what's coming next, straight to your inbox.", pt: "Prazos, novas turmas e próximas novidades direto no seu e-mail.", es: "Fechas límite, nuevas cohortes y lo que viene, directo a tu correo." } },
];

/* ---------- Planned events (no fixed dates yet) ---------- */
const EVENTS = [
  { icon: "👋", audience: "intl", format: "inperson",
    title: { en: "Welcome Week meetup for international students", pt: "Encontro de boas-vindas para estudantes internacionais", es: "Encuentro de bienvenida para estudiantes internacionales" },
    desc: { en: "Meet other new arrivals, swap tips on banking and phones, and find your people in week one.", pt: "Conheça outros recém-chegados, troque dicas de banco e celular e encontre sua turma na primeira semana.", es: "Conoce a otros recién llegados, comparte consejos de banco y teléfono y encuentra tu grupo en la primera semana." } },
  { icon: "🗓️", audience: "first", format: "inperson",
    title: { en: "Course registration help night", pt: "Noite de ajuda com a matrícula", es: "Noche de ayuda con la inscripción" },
    desc: { en: "Bring your laptop. Upperclassmen help first-years build a schedule that leaves room to go abroad.", pt: "Traga seu notebook. Veteranos ajudam calouros a montar uma grade que deixe espaço para o intercâmbio.", es: "Trae tu laptop. Estudiantes avanzados ayudan a armar un horario que deje espacio para el intercambio." } },
  { icon: "🎤", audience: "abroad", format: "inperson",
    title: { en: "Study Abroad in Year Two panel", pt: "Painel: intercâmbio no 2º ano", es: "Panel: intercambio en 2º año" },
    desc: { en: "Students who went abroad early share what they wish they had known as first-years.", pt: "Alunos que fizeram intercâmbio cedo contam o que gostariam de saber no primeiro ano.", es: "Estudiantes que salieron temprano cuentan lo que les hubiera gustado saber en primer año." } },
  { icon: "🍲", audience: "intl", format: "inperson",
    title: { en: "Global potluck", pt: "Potluck global", es: "Potluck global" },
    desc: { en: "Bring a dish from home and meet students from 20+ countries.", pt: "Traga um prato da sua terra e conheça alunos de mais de 20 países.", es: "Trae un plato de tu país y conoce estudiantes de más de 20 países." } },
  { icon: "🦘", audience: "abroad", format: "online",
    title: { en: "Sydney cohort kickoff call", pt: "Chamada de abertura da turma de Sydney", es: "Llamada de inicio de la cohorte de Sídney" },
    desc: { en: "Meet everyone heading to Sydney in the same term and split up the research: courses, housing, visas.", pt: "Conheça todo mundo que vai para Sydney no mesmo semestre e dividam a pesquisa: matérias, moradia, vistos.", es: "Conoce a todos los que van a Sídney en el mismo semestre y repartan la investigación: cursos, vivienda, visas." } },
  { icon: "🛫", audience: "intl", format: "online",
    title: { en: "Q&A night: visas and traveling home", pt: "Noite de perguntas: vistos e viagens para casa", es: "Noche de preguntas: visas y viajes a casa" },
    desc: { en: "Common questions about travel signatures, re-entry and planning trips home, answered by students who've done it.", pt: "Dúvidas comuns sobre assinatura de viagem, reentrada e viagens para casa, respondidas por quem já passou por isso.", es: "Preguntas comunes sobre firmas de viaje, reingreso y viajes a casa, respondidas por quienes ya lo vivieron." } },
];

/* ---------- Coming-soon features (Early access page) ----------
   status: "live" (works in the prototype), "soon" (being built), "planned" */
const ROADMAP = [
  { icon: "✅", status: "live", title: { en: "Orientation checklist", pt: "Checklist de orientação", es: "Checklist de orientación" }, desc: { en: "Visa, registration and daily-life steps for non-citizens.", pt: "Passos de visto, matrícula e dia a dia para não cidadãos.", es: "Pasos de visa, inscripción y vida diaria para no ciudadanos." } },
  { icon: "🎯", status: "live", title: { en: "Smart club directory", pt: "Diretório de clubes", es: "Directorio de clubes" }, desc: { en: "Freshman-friendly clubs, searchable and filterable.", pt: "Clubes que acolhem calouros, com busca e filtros.", es: "Clubes para estudiantes nuevos, con búsqueda y filtros." } },
  { icon: "🤝", status: "live", title: { en: "Peer match preview", pt: "Prévia do Peer Match", es: "Vista previa de Peer Match" }, desc: { en: "Find peers by destination and term (demo profiles).", pt: "Encontre colegas por destino e semestre (perfis de demonstração).", es: "Encuentra compañeros por destino y semestre (perfiles de demostración)." } },
  { icon: "🎓", status: "soon", title: { en: "Verified .edu accounts", pt: "Contas verificadas .edu", es: "Cuentas verificadas .edu" }, desc: { en: "Sign in with your university email on any device.", pt: "Entre com seu e-mail da universidade em qualquer aparelho.", es: "Inicia sesión con tu correo universitario en cualquier dispositivo." } },
  { icon: "💬", status: "soon", title: { en: "Real cohort chats", pt: "Chats de turma de verdade", es: "Chats de cohorte reales" }, desc: { en: "Message real students going to the same place in the same term.", pt: "Converse com alunos reais que vão para o mesmo lugar no mesmo semestre.", es: "Habla con estudiantes reales que van al mismo lugar en el mismo semestre." } },
  { icon: "⏰", status: "soon", title: { en: "Deadline reminders", pt: "Lembretes de prazos", es: "Recordatorios de fechas" }, desc: { en: "Email nudges before study abroad and visa deadlines.", pt: "Avisos por e-mail antes dos prazos de intercâmbio e visto.", es: "Avisos por correo antes de las fechas de intercambio y visa." } },
  { icon: "🔁", status: "planned", title: { en: "Course equivalency finder", pt: "Buscador de equivalência de matérias", es: "Buscador de equivalencias de cursos" }, desc: { en: "See which courses abroad have counted for credit before.", pt: "Veja quais matérias no exterior já foram validadas antes.", es: "Mira qué cursos en el extranjero ya se convalidaron antes." } },
  { icon: "🏠", status: "planned", title: { en: "Housing & roommate board", pt: "Mural de moradia e colegas de quarto", es: "Tablero de vivienda y compañeros de cuarto" }, desc: { en: "Find housing and roommates with your cohort.", pt: "Encontre moradia e colegas de quarto com sua turma.", es: "Encuentra vivienda y compañeros de cuarto con tu cohorte." } },
  { icon: "📱", status: "planned", title: { en: "Mobile app", pt: "App para celular", es: "App móvil" }, desc: { en: "iOS and Android, with push notifications.", pt: "iOS e Android, com notificações.", es: "iOS y Android, con notificaciones." } },
];

/* ---------- Reviews ----------
   Reviews people send arrive in your email via Formspree.
   👉 Only paste REAL reviews here, after the person agreed to have it published.
   Example format:
   { name: "Ana P.", role: "1st-year · Brazil", rating: 5, text: "...", date: "2026-10-12" },
*/
const APPROVED_REVIEWS = [];
