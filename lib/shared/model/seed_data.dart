import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/service_user_response_model.dart';
import 'package:well_trust_mobile_app/features/meds/data/model/med_response_model.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/notes_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/visit_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/cqc_color_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

const currentUserName = 'Samir Okonjo';
const currentUserInitials = 'SO';
const currentUserRole = 'Senior Domiciliary Carer';
const currentUserArea = 'Kettering round';
const currentUserEmail = 'samir.okonjo@welltrust.example';
const currentUserPhone = '07700 900 142';

// Terminology — the source defaults the phone app to "clients".
const termSing = 'client';
const termPlural = 'clients';
const termSingCap = 'Client';
const termPluralCap = 'Clients';

const visitTypes = <String, VisitType>{
  'morning': VisitType('Morning call', '🌅'),
  'lunch': VisitType('Lunch call', '🍽️'),
  'tea': VisitType('Tea call', '☕'),
  'bedtime': VisitType('Bedtime call', '🛏️'),
  'welfare': VisitType('Welfare check', '👋'),
  'bath': VisitType('Bath visit', '🛁'),
  'live-in': VisitType('Extended block', '⏳'),
};

VisitType visitTypeLabel(String t) =>
    visitTypes[t] ?? const VisitType('Visit', '📍');

const cqcColours = <String, CqcColour>{
  'safe': CqcColour('Safe', 0xFFFBEAE8, 0xFFB85048),
  'effective': CqcColour('Effective', 0xFFEAF0EA, 0xFF5D7A58),
  'caring': CqcColour('Caring', 0xFFF6EFE0, 0xFF8C6A25),
  'responsive': CqcColour('Responsive', 0xFFEAEFF6, 0xFF1E3A6F),
  'wellled': CqcColour('Well-led', 0xFFF0EBE0, 0xFF44483F),
};

const tagOptions = <String>[
  'Mood',
  'Nutrition',
  'Medication',
  'Mobility',
  'Sleep',
  'Family',
  'Activities',
  'Skin integrity',
  'Behaviour',
  'Pain',
  'Personal care',
  'Memory',
  'Risk flag',
];

const noteTypes = <NoteType>[
  NoteType(
    id: 'personal-care',
    icon: '🌅',
    label: 'Personal care',
    desc: 'Bathing, dressing, hygiene, dignity',
    placeholder:
        'How did personal care go? Note any dignity considerations, level of assistance given, and how the person responded.',
    tags: ['Personal care'],
    cqcKey: 'caring',
    cqcQS: 'C1.2',
    cqcLabel: 'Caring · Treating with kindness',
  ),
  NoteType(
    id: 'nutrition',
    icon: '🍽️',
    label: 'Nutrition & hydration',
    desc: 'Meals, drinks, intake, appetite',
    placeholder:
        'What did they eat or drink? How much? Did they need help? Any preferences or concerns?',
    tags: ['Nutrition'],
    cqcKey: 'effective',
    cqcQS: 'E1.3',
    cqcLabel: 'Effective · How staff support people to eat and drink well',
  ),
  NoteType(
    id: 'mobility',
    icon: '🚶',
    label: 'Mobility',
    desc: 'Transfers, walking, equipment use',
    placeholder:
        'Describe the transfer or movement. Equipment used? Level of assistance? Any pain or hesitation?',
    tags: ['Mobility'],
    cqcKey: 'effective',
    cqcQS: 'E1.1',
    cqcLabel: 'Effective · Assessing needs',
  ),
  NoteType(
    id: 'medication',
    icon: '💊',
    label: 'Medication / PRN',
    desc: 'Specific med events, PRN given, side-effects',
    placeholder:
        'Which medication, dose, when, why (for PRN), and how the person responded.',
    tags: ['Medication'],
    cqcKey: 'safe',
    cqcQS: 'S1.5',
    cqcLabel: 'Safe · Medicines optimisation',
  ),
  NoteType(
    id: 'mood',
    icon: '😊',
    label: 'Mood & wellbeing',
    desc: 'Emotional state, engagement, conversation',
    placeholder:
        'How was their mood? Engagement levels? Any meaningful conversations or moments?',
    tags: ['Mood'],
    cqcKey: 'caring',
    cqcQS: 'C1.3',
    cqcLabel: 'Caring · Respecting equality and diversity',
  ),
  NoteType(
    id: 'sleep',
    icon: '🛏️',
    label: 'Sleep',
    desc: 'Night-time, settling, rest quality',
    placeholder:
        'How did they sleep? Any disturbances, check-ins, support needed overnight?',
    tags: ['Sleep'],
    cqcKey: 'effective',
    cqcQS: 'E1.2',
    cqcLabel: 'Effective · Delivering evidence-based care',
  ),
  NoteType(
    id: 'memory',
    icon: '🧠',
    label: 'Memory & cognition',
    desc: 'Confusion, lucid moments, orientation',
    placeholder:
        'Note specific observations. Lucid moments? Episodes of confusion? Triggers or comforts?',
    tags: ['Memory'],
    cqcKey: 'caring',
    cqcQS: 'C1.1',
    cqcLabel: 'Caring · Treating with respect',
  ),
  NoteType(
    id: 'family',
    icon: '👨‍👩‍👧',
    label: 'Family contact',
    desc: 'Visits, calls, family events',
    placeholder:
        'Who visited or called? Duration? Impact on the person — were they calmer, happier, more anxious?',
    tags: ['Family'],
    cqcKey: 'responsive',
    cqcQS: 'R1.1',
    cqcLabel: 'Responsive · Person-centred care',
  ),
  NoteType(
    id: 'activities',
    icon: '🎨',
    label: 'Activities',
    desc: 'Group events, hobbies, outings',
    placeholder:
        'Which activity? Level of participation? Did they enjoy it? Anything to repeat or change?',
    tags: ['Activities'],
    cqcKey: 'responsive',
    cqcQS: 'R1.2',
    cqcLabel: 'Responsive · Care that meets the needs of the person',
  ),
  NoteType(
    id: 'skin',
    icon: '🩹',
    label: 'Skin & body',
    desc: 'Skin checks, marks, pressure care',
    placeholder:
        'Where on the body? What did you see? Any change since the last check? Action taken?',
    tags: ['Skin integrity'],
    cqcKey: 'safe',
    cqcQS: 'S1.2',
    cqcLabel: 'Safe · Preventing harm from care',
  ),
  NoteType(
    id: 'behaviour',
    icon: '😟',
    label: 'Behaviour',
    desc: 'Distress, agitation, unusual behaviour',
    placeholder:
        'What was observed? Possible trigger? How you responded? Outcome? This helps build the picture for the team.',
    tags: ['Behaviour'],
    cqcKey: 'safe',
    cqcQS: 'S1.3',
    cqcLabel: 'Safe · Safeguarding',
  ),
  NoteType(
    id: 'general',
    icon: '📝',
    label: 'General observation',
    desc: "Anything that doesn't fit above",
    placeholder:
        "A general observation — anything worth noting that doesn't fit a specific category.",
    tags: [],
    cqcKey: 'wellled',
    cqcQS: 'W1.1',
    cqcLabel: 'Well-led · Continuous learning',
  ),
];

NoteType noteTypeById(String id) =>
    noteTypes.firstWhere((t) => t.id == id, orElse: () => noteTypes.last);

const serviceUsers = <ServiceUser>[
  ServiceUser(
    id: 'su-patel',
    initials: 'AP',
    name: 'Anita Patel',
    age: 84,
    address: '14 Linden Avenue, Kettering NN15 6JL',
    keySafe: '1986',
    weeklyHours: '14h/week · 4 calls/day',
    flags: [
      Flag('falls', 'Falls risk'),
      Flag('allergy', 'Allergy: penicillin'),
    ],
    summary:
        'Vascular dementia, lives alone. Daughter visits weekends. Independent with prompting; needs help with personal care morning and bedtime.',
    nok: 'Priya Patel (daughter) · 07700 900201',
    gp: 'Dr Reeves, Kettering Medical Centre',
  ),
  ServiceUser(
    id: 'su-davies',
    initials: 'GD',
    name: 'George Davies',
    age: 78,
    address: '52 Beech Drive, Kettering NN15 5GG',
    keySafe: '2104',
    weeklyHours: '7h/week · 3 calls/day',
    flags: [],
    summary:
        'Heart failure, stable. Lives with wife (84) who does most personal care; we prompt meds and check welfare. Loves rugby.',
    nok: 'Mary Davies (wife) · in the home',
    gp: 'Dr Reeves, Kettering Medical Centre',
  ),
  ServiceUser(
    id: 'su-henderson',
    initials: 'EH',
    name: 'Edna Henderson',
    age: 91,
    address: '8 Mill Cottages, Geddington NN14 1AY',
    keySafe: '9521',
    weeklyHours: '21h/week · 4 calls/day incl. bath visit',
    flags: [
      Flag('dementia', 'Dementia'),
      Flag('falls', 'Falls risk'),
      Flag('dnar', 'DNAR'),
    ],
    summary:
        "Alzheimer's, advanced. Needs full personal care. DNAR in place. Husband Wilf died last year; lives alone with no family nearby. Daughter Karen visits monthly from Sheffield.",
    nok: 'Karen Henderson (daughter) · 07700 900445',
    gp: 'Dr Singh, Geddington Surgery',
  ),
  ServiceUser(
    id: 'su-akinola',
    initials: 'OA',
    name: 'Oluwaseun Akinola',
    age: 72,
    address: 'Flat 4, Albion Court, Kettering NN16 0DT',
    keySafe: '8847',
    weeklyHours: '3.5h/week · 2 short calls/day',
    flags: [],
    summary:
        'Diabetic, partially sighted. Independent but needs meds prompted, fridge stocked, and welfare checked. Lives alone in sheltered housing. Devout Christian — observes Sunday rest.',
    nok: 'Pastor John Adeleke · 07700 900778',
    gp: 'Dr Reeves, Kettering Medical Centre',
  ),
  ServiceUser(
    id: 'su-oconnor',
    initials: 'MO',
    name: "Maeve O'Connor",
    age: 86,
    address: '11 Rosedale Walk, Burton Latimer NN15 5XB',
    keySafe: '3320',
    weeklyHours: '10.5h/week · 3 longer calls/day',
    flags: [Flag('falls', 'Falls risk')],
    summary:
        'Severe arthritis, mobility limited. Sharp mind, fierce independence. Needs help with cooking, transfers, bath. Husband Frank passed two years ago. Catholic — likes to listen to Radio Maria.',
    nok: "Sean O'Connor (son) · 07700 900112",
    gp: 'Dr Singh, Burton Surgery',
  ),
  ServiceUser(
    id: 'su-kowalski',
    initials: 'TK',
    name: 'Tadeusz Kowalski',
    age: 79,
    address: '29 Cedar Close, Kettering NN15 7HP',
    keySafe: '5566',
    weeklyHours: '5.25h/week · 3 calls/day',
    flags: [Flag('allergy', 'Allergy: shellfish')],
    summary:
        'Recovering from hip replacement (6 weeks post-op). Polish speaker — English functional but reverts to Polish when tired. Wife Halina manages most care; we provide morning bath and meds.',
    nok: 'Halina Kowalska (wife) · in the home',
    gp: 'Dr Reeves, Kettering Medical Centre',
  ),
];

ServiceUser? suById(String id) {
  for (final s in serviceUsers) {
    if (s.id == id) return s;
  }
  return null;
}

ServiceUser? suByName(String name) {
  for (final s in serviceUsers) {
    if (s.name == name) return s;
  }
  return null;
}

const suProfiles = <String, SuProfile>{
  'su-patel': SuProfile(
    preferredName: 'Anita (please use Mrs Patel until I say otherwise)',
    aboutMe:
        'I worked as a primary school teacher in Leicester for 32 years. I have three grandchildren — Aarav (8), Maya (6), and Rohan (3). My husband Rajesh passed in 2019. I grew up in Mumbai and came to England when I was 22.',
    important:
        "I have vascular dementia. On good days I remember everything. On bad days I get confused and frightened. Please be patient and don't correct me — gently redirect.",
    likes: [
      'Hot chai with cardamom (NOT tea bags!)',
      'Bollywood films from the 60s',
      'The smell of fresh marigolds',
      'Talking about my grandchildren',
      "Photos of Aarav's cricket",
    ],
    dislikes: [
      'Being rushed',
      'The TV being too loud',
      'Tea bags (please use loose-leaf)',
      'Cold rooms — I feel it in my bones',
      'Being called "love" or "dear" — use my name',
    ],
    communication:
        'I speak fluent English but on bad days I revert to Gujarati. The phrase "ben" means sister — I may call you that, it\'s a sign of trust.',
    family:
        'My daughter Priya visits Saturday mornings. She has a key. If anything is wrong, call her first — she lives 20 mins away. My son lives in Canada and worries terribly when he doesn\'t hear from me.',
    spiritual:
        "Hindu. I light a small lamp at my shrine each morning. Please don't touch the photos or the lamp. The shrine is on the windowsill in the front room.",
    food:
        'Vegetarian. No beef, no pork, no eggs. I cook my own when I can — Priya brings me prepared meals on Sundays.',
    lastReviewedBy: 'My daughter Priya · 14 Mar 2026',
    lastReviewedNote:
        'Updated by Priya to add the cardamom-tea preference and to remove the old phone number for my son.',
  ),
  'su-davies': SuProfile(
    preferredName: 'George (or Georgie, my wife calls me that)',
    aboutMe:
        'I was a long-distance lorry driver for 40 years — drove all over Europe before retirement. Mary and I have been married 56 years. We have one daughter, Helen, who lives in Australia, and a son David who lives nearby in Northampton.',
    important:
        "My heart isn't great but my mind is sharp. Don't talk down to me. Mary does most of my care and I prefer it that way — your job is to help her, not me.",
    likes: [
      'Rugby (Northampton Saints fan)',
      'A weak cup of tea, milk no sugar',
      'BBC Radio 5 sports commentary',
      'Quiet chat about the news',
      "Sitting in the garden when it's sunny",
    ],
    dislikes: [
      'Fuss',
      'Sympathy',
      "People treating Mary as if she's the patient",
      'Soaps on TV',
    ],
    communication:
        "Speak clearly — I'm a bit deaf in the right ear. Look at me when you talk.",
    family:
        'Mary is here all the time and knows everything. She gets tired so please ask her how she is too.',
    spiritual:
        "C of E but not practising. Don't want a vicar. We had Mary's sister's funeral done at St Mary's in Kettering and that was enough religion for a lifetime.",
    food:
        'Whatever Mary cooks. I have a sweet tooth — Mary will tell you off if you let me have biscuits before tea.',
    lastReviewedBy: 'Self (with Mary present) · 28 Feb 2026',
    lastReviewedNote:
        'Mary added the bit about her getting tired. I told them to stop calling me Mr Davies — George is fine.',
  ),
  'su-henderson': SuProfile(
    preferredName: "Edna (Mrs Henderson on bad days when I don't know you)",
    aboutMe:
        'I was a nurse at Kettering General for 38 years. My husband Wilf was a baker in town — we met at a dance in 1952 and married six months later. We had no children. Wilf passed last year.',
    important:
        "I have advanced Alzheimer's. Most days I don't know what year it is. I get distressed in the bath — please go slowly. I have a DNAR in place — Karen has the paperwork.",
    likes: [
      'Hymns (especially "Abide With Me")',
      'The cat Tibbles (NOT my cat, but he comes round)',
      "Hand cream — Yardley's English Rose",
      'Sitting by the window',
    ],
    dislikes: [
      'Loud noises (especially the doorbell — please knock instead)',
      'Strangers in the kitchen',
      'Being hurried',
      'Bright overhead lights',
      'The TV news (it upsets me)',
    ],
    communication:
        "On good days I remember names. On bad days I might call you Wilf or by my sister's name (Doris). Don't correct me — just answer.",
    family:
        "My daughter Karen lives in Sheffield and visits monthly. Her number is on the fridge. I don't have any siblings still living.",
    spiritual:
        "Methodist. I used to go to the church on the high street. I'd like to hear hymns sometimes. There's a hymn book on the bookshelf.",
    food:
        'I forget to eat. Please make sure I have something at lunchtime, even if it\'s just a sandwich. I love tinned peaches with evaporated milk.',
    lastReviewedBy:
        'Karen Henderson (daughter, with care co-ordinator) · 02 Apr 2026',
    lastReviewedNote:
        "Karen wrote most of this from Mum's old diary and what Mum tells her on calls. Added the bath anxiety — important the carers know.",
  ),
  'su-akinola': SuProfile(
    preferredName:
        "Mr Akinola (please don't call me by my first name unless I invite you)",
    aboutMe:
        'I came to England from Nigeria in 1972. Worked as an engineer at British Rail for many years. I was a deacon at my church for 30 years. My wife passed in 2014. My children are scattered — one in Lagos, one in Birmingham, one in Atlanta.',
    important:
        "I am partially sighted (my right eye is gone, my left is poor). I am diabetic. I do most things for myself — your job is to prompt my meds, check I've eaten, and stock the fridge weekly. I don't need help in the bathroom and I will tell you if that changes.",
    likes: [
      'Gospel music (Mahalia Jackson in particular)',
      'Strong sweet tea',
      'The football scores read out',
      "My church's newsletter — Pastor John drops it round",
    ],
    dislikes: [
      'People moving things in my flat (I know where everything is by touch)',
      'Pity',
      'Pork',
      'Being asked about my eyes',
    ],
    communication:
        "Speak normally — my hearing is good. Tell me where you're moving to in the flat so I can track you.",
    family:
        'Pastor John Adeleke is my emergency contact — closer than family really. My daughter in Birmingham calls every Sunday.',
    spiritual:
        "Pentecostal Christian. I pray three times a day. Sundays are sacred — please don't visit between 9am–1pm Sunday unless it's urgent.",
    food:
        'No pork. I like Nigerian food — pounded yam, jollof rice. My daughter brings frozen meals when she visits.',
    lastReviewedBy: 'Self · 18 Jan 2026',
    lastReviewedNote:
        'I wrote this myself with Pastor John reading it back to me. No changes since.',
  ),
  'su-oconnor': SuProfile(
    preferredName:
        "Maeve (never Mrs O'Connor — that's my mother-in-law and she was a terror)",
    aboutMe:
        'Born in Galway, came to England in 1958 to nurse. Married Frank, an Englishman, in 1962. He passed in 2024. We never had children. I still have a strong Irish accent and a stronger Irish temper.',
    important:
        "My arthritis is severe. Some days I can't open jars or do up buttons. Please ask before helping — I hate being helped without being asked. I'm sharp as a tack mentally so don't talk to me like I'm senile.",
    likes: [
      'Radio Maria (Catholic radio)',
      'Strong coffee (NOT instant)',
      'Real butter on toast',
      'Politics chat',
      'Frank Sinatra',
    ],
    dislikes: [
      'Being called "love" or "pet"',
      'Carers who are on their phone during a visit',
      'Margarine',
      'Daytime TV',
    ],
    communication:
        "Don't shout — I'm not deaf, I'm just Irish. Look me in the eye.",
    family:
        'My son Sean lives in Dublin. He calls Wednesdays. My niece Aoife is local — Kettering — and has a key.',
    spiritual:
        "Catholic. I go to confession monthly. There's a small crucifix above the bed — please don't move it. Father Brendan from St Edward's drops in once a fortnight.",
    food:
        'Plain Irish food. Stew, potatoes, soda bread. No spicy things. A glass of Guinness on Friday evening is part of my care plan and I will not be told otherwise.',
    lastReviewedBy: 'Self (with Sean on the phone) · 22 May 2026',
    lastReviewedNote:
        'Updated to add Father Brendan visit times and the Guinness clause. Sean made me put in writing that the Guinness is doctor-approved.',
  ),
  'su-kowalski': SuProfile(
    preferredName: 'Tadek (Tadeusz on official forms)',
    aboutMe:
        'Born in Krakow in 1947. Came to England in 1968 as a young engineer. Halina is my second wife — we married 30 years ago. My first wife Anna passed in 1990. I have one son Marek in Krakow.',
    important:
        "I had my hip replaced 6 weeks ago and I'm recovering well but slowly. Halina does most of my care. When I get tired or in pain I revert to Polish — please be patient. My English is fine when I'm rested.",
    likes: [
      'Polish folk music',
      'Strong black coffee (NO milk, please)',
      'Pierogi',
      'Chess',
      'Looking at old photos of Krakow',
    ],
    dislikes: [
      'Being told to slow down',
      'British weather complaints (I love the rain)',
      'Sweet things',
      'Anyone touching my chess set',
    ],
    communication:
        "Speak clearly and slowly when I'm tired. The words I most often forget in English are body-part words — point if you're not sure I understand.",
    family:
        "Halina is here. She speaks better English than me when she wants to. Don't talk over her — she's my advocate.",
    spiritual:
        "Catholic but lapsed. Halina is more devout. I don't want last rites unless I ask.",
    food:
        "Polish food when Halina makes it. Otherwise simple — eggs, bread, soup. No British puddings, they're too sweet.",
    lastReviewedBy: 'Halina (with Tadek beside her) · 12 Apr 2026',
    lastReviewedNote:
        'Halina dictated, Tadek nodded and corrected. Updated post-surgery notes.',
  ),
};

SuProfile? profileForSu(String suId) => suProfiles[suId];

List<VisitResponseModel> seedVisits() => [
  VisitResponseModel(
    id: 'v1',
    suId: 'su-patel',
    start: '07:30',
    end: '08:00',
    duration: 30,
    type: 'morning',
    travelMin: 0,
    status: VisitStatus.complete,
    actualStart: '07:32',
    actualEnd: '08:02',
    tasks: ['Personal care', 'Breakfast prompt', 'Morning meds', 'Make bed'],
    visitNotes:
        "Settled morning. Took meds well. Toast and tea. Reminded her of daughter's visit Saturday.",
  ),
  VisitResponseModel(
    id: 'v2',
    suId: 'su-davies',
    start: '08:15',
    end: '08:45',
    duration: 30,
    type: 'morning',
    travelMin: 8,
    status: VisitStatus.complete,
    actualStart: '08:18',
    actualEnd: '08:41',
    tasks: ['Welfare check', 'Morning meds', 'Help with breakfast'],
    gapReason: 'Mary had breakfast under control — left early with agreement.',
    visitNotes:
        "Mary doing well today. Mr Davies in good form, talking about Saturday's match.",
  ),
  VisitResponseModel(
    id: 'v3',
    suId: 'su-henderson',
    start: '09:00',
    end: '10:00',
    duration: 60,
    type: 'bath',
    travelMin: 18,
    status: VisitStatus.complete,
    actualStart: '09:08',
    actualEnd: '10:12',
    tasks: [
      'Bath',
      'Full personal care',
      'Dressing',
      'Hair',
      'Breakfast',
      'Morning meds',
    ],
    gapReason:
        'Bath took longer — she was very anxious. Worth recording for the care plan review.',
    visitNotes:
        'Bath was difficult — Edna very distressed when water ran. Used the chair, talked her through. Took 50 min for bath alone. Will discuss with co-ordinator.',
  ),
  VisitResponseModel(
    id: 'v4',
    suId: 'su-akinola',
    start: '10:30',
    end: '10:45',
    duration: 15,
    type: 'welfare',
    travelMin: 12,
    status: VisitStatus.complete,
    actualStart: '10:33',
    actualEnd: '10:46',
    tasks: ['Welfare check', 'Mid-morning meds', 'Fluids prompt'],
    visitNotes:
        'All well. Met his neighbour at the door. Took meds, drank a full glass of water.',
  ),
  VisitResponseModel(
    id: 'v5',
    suId: 'su-oconnor',
    start: '12:00',
    end: '13:00',
    duration: 60,
    type: 'lunch',
    travelMin: 15,
    status: VisitStatus.inProgress,
    actualStart: '12:04',
    tasks: ['Lunch prep', 'Eating support', 'Lunch meds', 'Toilet', 'Bin out'],
  ),
  VisitResponseModel(
    id: 'v6',
    suId: 'su-patel',
    start: '12:30',
    end: '12:45',
    duration: 15,
    type: 'lunch',
    travelMin: 6,
    status: VisitStatus.scheduled,
    tasks: ['Lunch prompt', 'Lunch meds', 'Fluids'],
  ),
  VisitResponseModel(
    id: 'v7',
    suId: 'su-kowalski',
    start: '13:30',
    end: '14:00',
    duration: 30,
    type: 'lunch',
    travelMin: 14,
    status: VisitStatus.scheduled,
    tasks: ['Lunch prompt', 'Wound check (hip)', 'Lunch meds'],
  ),
  VisitResponseModel(
    id: 'v8',
    suId: 'su-henderson',
    start: '14:30',
    end: '15:00',
    duration: 30,
    type: 'welfare',
    travelMin: 20,
    status: VisitStatus.scheduled,
    tasks: ['Welfare check', 'Toilet', 'Fluids', 'Change of position'],
  ),
  VisitResponseModel(
    id: 'v9',
    suId: 'su-davies',
    start: '16:00',
    end: '16:15',
    duration: 15,
    type: 'tea',
    travelMin: 22,
    status: VisitStatus.scheduled,
    tasks: ['Tea prompt', 'Afternoon meds'],
  ),
  VisitResponseModel(
    id: 'v10',
    suId: 'su-akinola',
    start: '17:00',
    end: '17:15',
    duration: 15,
    type: 'tea',
    travelMin: 10,
    status: VisitStatus.scheduled,
    tasks: ['Welfare check', 'Tea meds', 'Curtains/lights'],
  ),
  VisitResponseModel(
    id: 'v11',
    suId: 'su-oconnor',
    start: '18:00',
    end: '18:45',
    duration: 45,
    type: 'tea',
    travelMin: 18,
    status: VisitStatus.scheduled,
    tasks: ['Dinner prep', 'Eating support', 'Toilet', 'Settle for evening'],
  ),
  VisitResponseModel(
    id: 'v12',
    suId: 'su-patel',
    start: '19:30',
    end: '20:00',
    duration: 30,
    type: 'bedtime',
    travelMin: 8,
    status: VisitStatus.scheduled,
    tasks: [
      'Bedtime meds',
      'Personal care',
      'Settle in bed',
      'Night light check',
    ],
  ),
  VisitResponseModel(
    id: 'v13',
    suId: 'su-henderson',
    start: '20:30',
    end: '21:00',
    duration: 30,
    type: 'bedtime',
    travelMin: 18,
    status: VisitStatus.scheduled,
    tasks: ['Bedtime meds', 'Brush teeth', 'Help to bed', 'Continence pad'],
  ),
];

List<MarRecord> seedMar() => [
  MarRecord(
    suId: 'su-patel',
    resident: 'Anita Patel',
    initials: 'AP',
    meds: [
      Med(
        time: '08:00',
        name: 'Donepezil 10mg',
        dose: '1 tablet · oral',
        status: 'done',
      ),
      Med(
        time: '08:00',
        name: 'Memantine 10mg',
        dose: '1 tablet · oral',
        status: 'done',
      ),
      Med(
        time: '12:30',
        name: 'Paracetamol 500mg',
        dose: '2 tablets · oral · PRN',
        status: 'due',
      ),
      Med(
        time: '19:30',
        name: 'Memantine 10mg',
        dose: '1 tablet · oral · bedtime',
        status: 'due',
      ),
    ],
  ),
  MarRecord(
    suId: 'su-davies',
    resident: 'George Davies',
    initials: 'GD',
    meds: [
      Med(
        time: '08:30',
        name: 'Ramipril 5mg',
        dose: '1 tablet · oral · morning',
        status: 'done',
      ),
      Med(
        time: '08:30',
        name: 'Furosemide 40mg',
        dose: '1 tablet · oral · morning',
        status: 'done',
      ),
      Med(
        time: '16:00',
        name: 'Bisoprolol 2.5mg',
        dose: '1 tablet · oral · afternoon',
        status: 'due',
      ),
    ],
  ),
  MarRecord(
    suId: 'su-henderson',
    resident: 'Edna Henderson',
    initials: 'EH',
    meds: [
      Med(
        time: '09:30',
        name: 'Rivastigmine patch 9.5mg',
        dose: '1 patch · transdermal · daily',
        status: 'done',
      ),
      Med(
        time: '09:30',
        name: 'Risperidone 0.5mg',
        dose: '1 tablet · oral · with food',
        status: 'done',
      ),
      Med(
        time: '14:30',
        name: 'Paracetamol 1g',
        dose: 'oral · PRN for arthritis pain',
        status: 'due',
      ),
      Med(
        time: '20:30',
        name: 'Trazodone 50mg',
        dose: '1 tablet · oral · bedtime for sleep',
        status: 'due',
      ),
    ],
  ),
  MarRecord(
    suId: 'su-akinola',
    resident: 'Oluwaseun Akinola',
    initials: 'OA',
    meds: [
      Med(
        time: '10:30',
        name: 'Metformin 500mg',
        dose: '1 tablet · oral · with food',
        status: 'due',
      ),
      Med(
        time: '17:00',
        name: 'Metformin 500mg',
        dose: '1 tablet · oral · with food',
        status: 'due',
      ),
      Med(
        time: '17:00',
        name: 'Atorvastatin 20mg',
        dose: '1 tablet · oral',
        status: 'due',
      ),
    ],
  ),
  MarRecord(
    suId: 'su-oconnor',
    resident: "Maeve O'Connor",
    initials: 'MO',
    meds: [
      Med(
        time: '12:00',
        name: 'Naproxen 500mg',
        dose: '1 tablet · oral · with food',
        status: 'due',
      ),
      Med(
        time: '12:00',
        name: 'Omeprazole 20mg',
        dose: '1 capsule · oral · before food',
        status: 'due',
      ),
      Med(
        time: '18:00',
        name: 'Naproxen 500mg',
        dose: '1 tablet · oral · with food',
        status: 'due',
      ),
    ],
  ),
  MarRecord(
    suId: 'su-kowalski',
    resident: 'Tadeusz Kowalski',
    initials: 'TK',
    meds: [
      Med(
        time: '13:30',
        name: 'Apixaban 2.5mg',
        dose: '1 tablet · oral',
        status: 'due',
      ),
      Med(
        time: '13:30',
        name: 'Paracetamol 1g',
        dose: 'PRN for hip pain',
        status: 'due',
      ),
    ],
  ),
];

List<Competency> seedCompetencies() => [
  Competency(
    id: 'cmp1',
    title: 'Safe medication administration (domiciliary)',
    icon: '💊',
    status: 'acknowledged',
    signedAt: '12 Feb 2026',
    assessor: 'James Whitfield, RGN',
    standard:
        'Demonstrate safe practice for prompting, observing, and recording medication during dom visits. 6 rights of administration applied at the doorstep. Accurate MAR recording per visit.',
    evidence: 'Observed by RGN on 3 separate visits. Quiz score 96%.',
  ),
  Competency(
    id: 'cmp2',
    title: 'Moving & handling',
    icon: '🚶',
    status: 'acknowledged',
    signedAt: '08 Jan 2026',
    assessor: 'Pat Henderson, Physio',
    standard:
        "Use of hoists, slide sheets, transfer boards in the client's home environment. Safe positioning. Risk assessment use.",
    evidence: 'Training certificate + workplace assessment completed.',
  ),
  Competency(
    id: 'cmp3',
    title: 'Dementia care competency',
    icon: '🧠',
    status: 'pending',
    dueBy: '15 Jun 2026',
    standard:
        'Person-centred care for clients living with dementia. Communication strategies. Recognising and responding to distress. Validation therapy basics.',
    evidence:
        '8-hour eLearning module + 1-day workshop + workplace observation.',
  ),
  Competency(
    id: 'cmp4',
    title: 'Lone working & home environment safety',
    icon: '🚪',
    status: 'pending',
    dueBy: '22 Jun 2026',
    standard:
        'Entering the home safely. Recognising hazards (slips, hostile family, pets). Safety check-in protocols. Escalation routes when concerned.',
    evidence: 'eLearning + scenario assessment + buddy shadow.',
  ),
  Competency(
    id: 'cmp5',
    title: 'First aid (annual refresher)',
    icon: '🆘',
    status: 'expired',
    dueBy: '12 May 2026',
    standard:
        'CPR, AED use, recovery position, choking response, common medical emergencies. Especially relevant when working alone in the community.',
    evidence: 'Practical assessment + multiple-choice test.',
  ),
];

List<Policy> seedPolicies() => [
  Policy(
    id: 'pol1',
    title: 'Safeguarding adults policy',
    icon: '🛡️',
    version: 'v3.2',
    status: 'pending',
    publishedAt: '24 May 2026',
    summary:
        'How to recognise, respond to, and report concerns about abuse or neglect of adults at risk in their own homes. Defines the safeguarding lead, the local authority safeguarding team, and your duty of candour.',
    keyPoints: [
      'Recognise the 10 types of abuse',
      'Report any concern within 24 hours',
      'Use the safeguarding alert form in the app',
      'Whistleblowing protection applies',
    ],
  ),
  Policy(
    id: 'pol2',
    title: 'Medication policy (domiciliary)',
    icon: '💊',
    version: 'v2.1',
    status: 'acknowledged',
    acknowledgedAt: '14 Feb 2026',
    summary:
        "Procedures for prompting, observing and recording medication during dom visits. Storage in the client's home. PRN authorisation.",
  ),
  Policy(
    id: 'pol3',
    title: 'Whistleblowing policy',
    icon: '📢',
    version: 'v1.4',
    status: 'acknowledged',
    acknowledgedAt: '08 Jan 2026',
    summary:
        'Your protected right to raise concerns. Anonymous reporting available. No reprisal.',
  ),
  Policy(
    id: 'pol4',
    title: 'Data protection / GDPR',
    icon: '🔐',
    version: 'v2.0',
    status: 'pending',
    publishedAt: '20 May 2026',
    summary:
        'How we handle personal and special-category data. Your obligations under UK GDPR.',
    keyPoints: [
      'Never share client data outside the platform',
      'Use only your personal login — never share',
      'Report data breaches within 24h',
      'Photos require client consent',
    ],
  ),
  Policy(
    id: 'pol5',
    title: 'Infection control',
    icon: '🧼',
    version: 'v3.0',
    status: 'acknowledged',
    acknowledgedAt: '02 Mar 2026',
    summary:
        "Hand hygiene, PPE, outbreak response. Cleaning standards when working in someone's home.",
  ),
  Policy(
    id: 'pol6',
    title: 'Lone working',
    icon: '🚶‍♂️',
    version: 'v1.2',
    status: 'acknowledged',
    acknowledgedAt: '12 Feb 2026',
    summary:
        'Safety procedures when working alone in the community, especially at night and in unfamiliar properties.',
  ),
];

List<Declaration> seedDeclarations() => [
  Declaration(
    id: 'dec1',
    title: 'Annual health declaration',
    icon: '🩺',
    status: 'pending',
    dueBy: '12 Jun 2026 (12 days)',
    description:
        'Confirm you are medically fit to carry out your role and disclose any conditions that may affect your work.',
    questions: [
      'Are you currently fit and well to perform your duties?',
      'Do you have any medical conditions the office should be aware of?',
      'Are you taking any medication that could affect your work?',
    ],
  ),
  Declaration(
    id: 'dec2',
    title: 'Driving licence declaration',
    icon: '🚗',
    status: 'overdue',
    dueBy: '25 May 2026 (6 days late)',
    description:
        'Required for dom carers who drive between visits. Confirm licence is valid and disclose any points/conditions.',
    questions: [
      'Is your driving licence currently valid?',
      'Do you have any points or restrictions on your licence?',
      'Have you been involved in any incidents in the last 12 months?',
    ],
  ),
  Declaration(
    id: 'dec3',
    title: 'Conflict of interest declaration',
    icon: '⚖️',
    status: 'completed',
    completedAt: '04 Mar 2026',
    description:
        'Disclose any financial, family, or business relationships with clients or their families that may conflict with your duties.',
  ),
  Declaration(
    id: 'dec4',
    title: 'Flu/COVID vaccination status',
    icon: '💉',
    status: 'pending',
    dueBy: '30 Sep 2026',
    description:
        'Voluntary annual disclosure of vaccination status to support outbreak planning. Important for carers visiting vulnerable clients.',
    questions: [
      'Have you had your seasonal flu vaccine this year?',
      'Are you up to date with COVID boosters?',
    ],
  ),
];

const seedMeetings = <Meeting>[
  Meeting(
    id: 'm1',
    time: '09:00',
    title: 'Morning round briefing',
    who: 'Round team huddle by phone (Samir, Jenna, Aisha)',
    duration: '10 min',
    status: 'soon',
  ),
  Meeting(
    id: 'm2',
    time: '14:00',
    title: 'Care plan review · Mrs Henderson',
    who: 'You, the co-ordinator, daughter via video',
    duration: '30 min',
    status: 'scheduled',
  ),
  Meeting(
    id: 'm3',
    time: '17:00',
    title: 'End-of-day round wrap-up',
    who: 'Co-ordinator + all carers on rota',
    duration: '15 min',
    status: 'scheduled',
  ),
  Meeting(
    id: 'm4',
    time: 'Thu',
    title: 'Supervision · Maria (your manager)',
    who: '1-on-1 supervision in the office',
    duration: '45 min',
    status: 'thisweek',
  ),
  Meeting(
    id: 'm5',
    time: 'Fri',
    title: 'Mandatory training · Lone working in the community',
    who: 'All Kettering round carers',
    duration: '90 min',
    status: 'thisweek',
  ),
];

List<StaffMessage> seedMessages() => [
  const StaffMessage(
    from: 'Maria Reyes',
    initials: 'MR',
    mine: false,
    text:
        "Morning Samir — Mrs Henderson's bath visit is going to be tricky today. She was anxious yesterday. Take your time, no pressure on the next visit.",
    time: '08:14',
  ),
  const StaffMessage(
    from: 'You',
    initials: 'SO',
    mine: true,
    text: "Will do. I'll add a calming routine note for next carer.",
    time: '08:16',
  ),
  const StaffMessage(
    from: 'Maria Reyes',
    initials: 'MR',
    mine: false,
    text:
        "Brilliant, thank you. Also — Mr Davies's wife called. He had a wobbly night. Please give them extra time at the morning call.",
    time: '08:17',
  ),
  const StaffMessage(
    from: 'Jenna L.',
    initials: 'JL',
    mine: false,
    text:
        "Sam I'm running 10 min late to Mrs O'Connor — traffic on the A14. Could you flex your lunch round to start with Mrs Patel first?",
    time: '11:32',
  ),
];
