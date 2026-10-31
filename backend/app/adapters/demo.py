from datetime import datetime, timezone

from app.adapters.base import DataSourceAdapter
from app.adapters.id_mapper import map_external_id

SOURCE_NAME = "demo"

CATEGORIES = [
    {"id": "cat-xianxia", "name": "仙侠"},
    {"id": "cat-wuxia", "name": "武侠"},
    {"id": "cat-sci-fi", "name": "科幻"},
    {"id": "cat-romance", "name": "言情"},
    {"id": "cat-mystery", "name": "悬疑"},
    {"id": "cat-classic", "name": "古典文学"},
]

_BOOKS_RAW = [
    {
        "external_id": "demo-001",
        "title": "山海经异闻录",
        "author": "佚名",
        "cover_url": None,
        "description": "取材于上古奇书《山海经》，讲述上古洪荒时代的奇幻故事。本书为公开域改编示例文本。",
        "serial_status": "completed",
        "categories": ["仙侠", "古典文学"],
        "chapters": [
            {"title": "第一章 洪荒初开", "content": "天地混沌如鸡子，盘古生其中。万八千岁，天地开辟，阳清为天，阴浊为地。\n\n盘古在其中，一日九变，神于天，圣于地。天日高一丈，地日厚一丈，盘古日长一丈。如此万八千岁，天数极高，地数极深，盘古极长。\n\n后乃有三皇。数起于一，立于三，成于五，盛于七，处于九，故天去地九万里。"},
            {"title": "第二章 精卫填海", "content": "又北二百里，曰发鸠之山，其上多柘木。有鸟焉，其状如乌，文首，白喙，赤足，名曰精卫，其鸣自詨。\n\n是炎帝之少女，名曰女娃。女娃游于东海，溺而不返，故为精卫。常衔西山之木石，以堙于东海。\n\n漳水出焉，东流注于河。"},
            {"title": "第三章 夸父逐日", "content": "夸父与日逐走，入日。渴欲得饮，饮于河、渭。河、渭不足，北饮大泽。\n\n未至，道渴而死。弃其杖，化为邓林。\n\n夸父不量力，欲追日景，逮之于禺谷。将饮河而不足也，将走大泽，未至，死于此。"},
            {"title": "第四章 鲲鹏南徙", "content": "北冥有鱼，其名为鲲。鲲之大，不知其几千里也。化而为鸟，其名为鹏。\n\n鹏之背，不知其几千里也。怒而飞，其翼若垂天之云。是鸟也，海运则将徙于南冥。\n\n南冥者，天池也。《齐谐》者，志怪者也。《谐》之言曰：鹏之徙于南冥也，水击三千里，抟扶摇而上者九万里，去以六月息者也。"},
        ],
    },
    {
        "external_id": "demo-002",
        "title": "桃花源新记",
        "author": "陶渊明",
        "cover_url": None,
        "description": "以陶渊明《桃花源记》为蓝本的公开域改编示例，讲述武陵渔人误入桃花源的奇遇。",
        "serial_status": "completed",
        "categories": ["古典文学"],
        "chapters": [
            {"title": "第一章 缘溪行", "content": "晋太元中，武陵人捕鱼为业。缘溪行，忘路之远近。忽逢桃花林，夹岸数百步，中无杂树，芳草鲜美，落英缤纷。\n\n渔人甚异之，复前行，欲穷其林。林尽水源，便得一山。山有小口，仿佛若有光。\n\n便舍船，从口入。初极狭，才通人。复行数十步，豁然开朗。"},
            {"title": "第二章 豁然开朗", "content": "土地平旷，屋舍俨然，有良田、美池、桑竹之属。阡陌交通，鸡犬相闻。\n\n其中往来种作，男女衣着，悉如外人。黄发垂髫，并怡然自乐。\n\n见渔人，乃大惊，问所从来。具答之。便要还家，设酒杀鸡作食。村中闻有此人，咸来问讯。"},
            {"title": "第三章 不足为外人道", "content": "自云先世避秦时乱，率妻子邑人来此绝境，不复出焉，遂与外人间隔。\n\n问今是何世，乃不知有汉，无论魏晋。此人一一为具言所闻，皆叹惋。\n\n余人各复延至其家，皆出酒食。停数日，辞去。此中人语云：不足为外人道也。"},
        ],
    },
    {
        "external_id": "demo-003",
        "title": "星河漫游者",
        "author": "未来居士",
        "cover_url": None,
        "description": "一部关于星际旅行的原创科幻示例文本，讲述人类在星河中寻找新家园的故事。",
        "serial_status": "ongoing",
        "categories": ["科幻"],
        "chapters": [
            {"title": "第一章 启航", "content": "公元2387年，人类文明的舰队从地球轨道出发，驶向半人马座阿尔法星系。\n\n舰长林远站在观星台上，望着逐渐远去的蓝色星球。这是人类第一次真正意义上的星际远航。\n\n\"启航完毕，曲率引擎已就绪。\"人工智能\"织女\"的声音在舰桥回荡。"},
            {"title": "第二章 曲率跃迁", "content": "曲率引擎启动的瞬间，星空仿佛被拉成了无数条光线。舰船在时空中滑行，穿越人类从未到达的区域。\n\n\"跃迁完成，当前位置距离地球4.2光年。\"织女报告道。\n\n林远看着舷窗外的陌生星域，心中涌起一股难以名状的激动。"},
            {"title": "第三章 新世界", "content": "探测器在比邻星b轨道上发现了疑似液态水的痕迹。舰队减速进入环绕轨道。\n\n\"大气成分分析完毕：氮气78%，氧气20%，其余为微量气体。宜居指数0.87。\"\n\n林远深吸一口气：\"准备派遣登陆舱。\""},
        ],
    },
    {
        "external_id": "demo-004",
        "title": "江湖夜雨十年灯",
        "author": "古道居士",
        "cover_url": None,
        "description": "一部原创武侠示例文本，讲述江湖侠客的恩怨情仇。",
        "serial_status": "ongoing",
        "categories": ["武侠"],
        "chapters": [
            {"title": "第一章 长亭外", "content": "长亭外，古道边，芳草碧连天。晚风拂柳笛声残，夕阳山外山。\n\n一匹瘦马踏着暮色缓缓行来，马上之人青衫磊落，腰悬三尺长剑。\n\n他叫沈归，十年前名震江湖的\"归剑客\"。十年后，他回来了。"},
            {"title": "第二章 旧雨来", "content": "客栈的灯火昏黄。沈归要了一壶浊酒，独坐窗前。\n\n\"这位兄台，可否借坐？\"一个粗豪声音响起。来人虬髯满面，背负一柄厚背刀。\n\n沈归抬眼看了看：\"赵铁刀？\"\n\"没想到沈兄还认得我。\"赵铁刀大笑落座。"},
        ],
    },
    {
        "external_id": "demo-005",
        "title": "雾中迷案",
        "author": "推理散人",
        "cover_url": None,
        "description": "一部原创悬疑推理示例文本，讲述侦探在浓雾中破解离奇案件。",
        "serial_status": "ongoing",
        "categories": ["悬疑"],
        "chapters": [
            {"title": "第一章 浓雾", "content": "深秋的江城被一场大雾笼罩。清晨六点，城东老宅传出尖叫。\n\n侦探陆明赶到现场时，雾仍未散。老宅书房内，富商周天成倒在血泊中，凶器不见踪影。\n\"门窗都是从内反锁的。\"助手小何低声道。陆明皱起了眉。"},
            {"title": "第二章 密室", "content": "密室杀人。陆明仔细检查了每一扇门窗。书房唯一通风的是壁炉烟囱，但烟囱仅一尺见方，常人绝不可能通过。\n\"死者手中攥着什么？\"陆明问。\n小何掰开僵硬的手指：一张纸条，上面只有三个字——\"雾知道\"。"},
        ],
    },
    {
        "external_id": "demo-006",
        "title": "月下花前集",
        "author": "婉约词人",
        "cover_url": None,
        "description": "一部原创言情示例文本，以诗词为引，讲述一段跨越四季的温柔故事。",
        "serial_status": "completed",
        "categories": ["言情"],
        "chapters": [
            {"title": "第一章 春日宴", "content": "春日宴，绿酒一杯歌一遍。再拜陈三愿：一愿郎君千岁，二愿妾身常健，三愿如同梁上燕，岁岁长相见。\n\n苏婉在花笺上写下这首词，轻轻放在窗台。春风拂过，花笺飘向隔壁的院子。\n\n\"好词。\"隔壁传来一声清朗的赞叹。"},
            {"title": "第二章 夏夜短", "content": "夏夜短，睡不足。苏婉与隔壁的书生顾辰已相识三月。\n\n\"明日我要赴京赶考。\"顾辰在墙头轻声道。苏婉沉默良久，递过一支玉簪：\"盼君早归。\""},
            {"title": "第三章 秋风起", "content": "秋风起，落叶黄。顾辰一去半年，音信全无。苏婉日日在院中等候。\n\n直到深秋某日，一匹快马停在巷口。来人递上一封书信和一支玉簪——正是她当初赠出的那支。"},
        ],
    },
]


def _build_books():
    books = []
    for raw in _BOOKS_RAW:
        book_id = map_external_id(SOURCE_NAME, raw["external_id"])
        chapters = []
        for idx, ch in enumerate(raw["chapters"]):
            ch_id = map_external_id(SOURCE_NAME, f"{raw['external_id']}-ch-{idx}")
            chapters.append({
                "id": ch_id,
                "external_id": f"{raw['external_id']}-ch-{idx}",
                "title": ch["title"],
                "content": ch["content"],
                "order": idx,
                "word_count": len(ch["content"]),
            })
        books.append({
            "id": book_id,
            "external_id": raw["external_id"],
            "title": raw["title"],
            "author": raw["author"],
            "cover_url": raw["cover_url"],
            "description": raw["description"],
            "serial_status": raw["serial_status"],
            "categories": raw["categories"],
            "latest_chapter_title": chapters[-1]["title"] if chapters else None,
            "chapters": chapters,
            "is_demo": True,
            "updated_at": datetime.now(timezone.utc),
        })
    return books


_BOOKS: list[dict] = []


def _ensure_loaded():
    global _BOOKS
    if not _BOOKS:
        _BOOKS = _build_books()


class DemoDataAdapter(DataSourceAdapter):
    def _find_book(self, book_id: str) -> dict | None:
        _ensure_loaded()
        return next((b for b in _BOOKS if b["id"] == book_id), None)

    async def list_books(self, *, page: int = 1, page_size: int = 20) -> dict:
        _ensure_loaded()
        total = len(_BOOKS)
        start = (page - 1) * page_size
        items = _BOOKS[start : start + page_size]
        return {"items": items, "total": total, "page": page, "page_size": page_size}

    async def list_recent_books(self, *, limit: int = 10) -> dict:
        _ensure_loaded()
        items = sorted(_BOOKS, key=lambda b: b["updated_at"], reverse=True)[:limit]
        return {"items": items, "total": len(items)}

    async def get_book(self, book_id: str) -> dict | None:
        return self._find_book(book_id)

    async def list_chapters(self, book_id: str) -> list[dict]:
        book = self._find_book(book_id)
        if not book:
            return []
        return [
            {"id": c["id"], "title": c["title"], "order": c["order"], "word_count": c["word_count"]}
            for c in book["chapters"]
        ]

    async def get_chapter(self, book_id: str, chapter_id: str) -> dict | None:
        book = self._find_book(book_id)
        if not book:
            return None
        for idx, ch in enumerate(book["chapters"]):
            if ch["id"] == chapter_id:
                prev_id = book["chapters"][idx - 1]["id"] if idx > 0 else None
                next_id = book["chapters"][idx + 1]["id"] if idx < len(book["chapters"]) - 1 else None
                return {
                    "id": ch["id"],
                    "title": ch["title"],
                    "content": ch["content"],
                    "order": ch["order"],
                    "word_count": ch["word_count"],
                    "prev_chapter_id": prev_id,
                    "next_chapter_id": next_id,
                    "is_demo": True,
                }
        return None

    async def search(self, keyword: str, *, scope: str = "both", page: int = 1, page_size: int = 20) -> dict:
        _ensure_loaded()
        kw = keyword.strip().lower()
        results = []
        for b in _BOOKS:
            match = False
            if scope in ("title", "both") and kw in b["title"].lower():
                match = True
            if scope in ("author", "both") and kw in b["author"].lower():
                match = True
            if match:
                results.append(b)
        total = len(results)
        start = (page - 1) * page_size
        items = results[start : start + page_size]
        return {"items": items, "total": total, "page": page, "page_size": page_size, "is_empty": total == 0}

    async def list_categories(self) -> list[dict]:
        return CATEGORIES

    async def list_books_by_category(self, category_id: str, *, page: int = 1, page_size: int = 20) -> dict:
        _ensure_loaded()
        cat = next((c for c in CATEGORIES if c["id"] == category_id), None)
        if not cat:
            return {"items": [], "total": 0, "page": page, "page_size": page_size, "is_empty": True}
        cat_name = cat["name"]
        results = [b for b in _BOOKS if cat_name in b["categories"]]
        total = len(results)
        start = (page - 1) * page_size
        items = results[start : start + page_size]
        return {"items": items, "total": total, "page": page, "page_size": page_size, "is_empty": total == 0}

    async def health_check(self) -> dict:
        return {"status": "ok", "mode": "demo", "message": "演示数据模式运行中"}