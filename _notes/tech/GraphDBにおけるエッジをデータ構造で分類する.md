---
title: GraphDBにおけるエッジをデータ構造で分類する
date: 2022-11-02
tags: Technology, Database Management, Graph Databases
publish: true
feed: show
---
# はじめに - グラフDB
グラフデーターベースとはグラフ構造を備えたデータベースのことで，従来のリレーショナルデータベースよりも格納や検索の面で優れていると言われています．
グラフは「ノード」「エッジ」「プロパティ」の3要素によって，ノード間の「関係性」を表現できます．ノードやプロパティはそれぞれエンティティとその属性と言い換えられ比較的理解しやすいのですが，エッジ（エンティティの関係または関連付け) はエンティティの関係性によって複数のパターンが考えられます．そのためここではいくつかのパターンを調べ上げ，具体例と共にしっかり理解していきたいと思います．

# 目標
 - リレーション設計がサクサクできるようになる
 - `CREATE(a: Person{name:"foo"})-[:FOLLOWS{from:"202010"}]->(b:Person{name:"bar"})`のようなarrow表記を見てもビビらなくなる


# エッジ入門
## Cardinality
手始めに，まず次のような関係性を考えてみましょう．
![er_user_pets_groups](https://entgo.io/images/assets/er_user_pets_groups.png)
Userエンティティは多くのPetを飼うことができますが，Petは1人のUserしか持つことができません．前者の「（UserがPetを）飼う」関係性をpets，後者の「（UserがPetを）所有する」関係性をownerと呼ぶことにします．
エッジの定義では，petsエッジはO2M(one-to-many)リレーションシップであり，ownerエッジはM2O(many-to-one)リレーションシップと呼ばれ，これらは同じ構造を持っています．
また，Groupエンティティには多くのUserが所属しており，またUserは複数のGroupを掛け持ちできます．このような場合，M2M(many-to-many)リレーションシップと呼ばれます．
このO2MやM2Mのような数的対応関係による分類を後ほどおこないます．

リレーショナルデータベースでは，このM2Mのケースでのみ**中間テーブル**（junction table）と呼ばれる2種類の外部キーを持つテーブルを新規に用意して結合させますが，グラフDBではM2MであれO2Mであれ「関係性」はすべてエッジとして区別されます．
リレーショナルデータベースにおける「リレーション」はあくまでオブジェクトとそのオブジェクトに関する情報を格納する意味だったのが，グラフデータベースにおける「エッジ」（リレーションシップとも呼ばれます）はオブジェクト間の関係性を表しているので意味が異なります．

## Directionality
エッジは必ず有向グラフであり「方向性」を有します．一般的には非対称ですが，対称な関係性を有するエッジの場合はBidirectional(双方向的)と呼ぶことにし，区別することとします．

## Types
エッジの両端に来る「型」もエッジのプロパティです．上記のUser-PetやGroup-Userのように一般的には異なる型ですが，同一の型を取る場合があるのでその場合も区別することとします．

# エッジの分類
上記の区別から次のように網羅的にエッジは書き下せると考えられます．
 - O2O, O2M, M2M
 - Two Types, Same Types
 - Bidirectional or not

一つ一つ見ていきます．なお双方向的である時は，定義からO2OもしくはM2Mでなければならず，O2Mは取れないことに注意してください．

なお，エッジの分類ではSurrealDBの実際のクエリも記載します．SurrealDBではSQLに似た構文でエッジを定義することができます．大事なことは次の2点です．
 - `{table}:{id}`が主キーであること
 - [`RELATE` statement](https://surrealdb.com/docs/surrealql/statements/relate)は
```
RELATE @from -> @table -> @with
```
という形式を必ずとり，`->`が2つ続き，両端にはノード，中央にエッジ名称が来ること．
興味がある方は是非手元で動かしてみてください．


## O2O Two Types
![o2oTwo](https://entgo.io/images/assets/er_user_card.png)
この例では，あるUserは1枚だけクレジットカードを持ち，またクレジットカードもまた1人の所有者しか持ちません．少し頼りないですが，簡素なECサイトとしてはとりあえずありでしょう．
ここでは川平慈英が楽天カードを持つ例をクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE User:kabira SET
    age = 60,
    name = '川平慈英'
;
CREATE Card:rakuten SET
    number = 1234567890,
    expired = '2099/12/31'
;
RELATE User:kabira->card->Card:rakuten;
RELATE Card:rakuten->owner->User:kabira;
```
:::details 結果
```json
[
    {
        "time": "761.365µs",
        "status": "OK",
        "result": [
            {
                "age": 60,
                "id": "User:kabira",
                "name": "川平慈英"
            }
        ]
    },
    {
        "time": "85.559µs",
        "status": "OK",
        "result": [
            {
                "expired": "2099/12/31",
                "id": "Card:rakuten",
                "number": 1234567890
            }
        ]
    },
    {
        "time": "170.572µs",
        "status": "OK",
        "result": [
            {
                "id": "card:7jfnab7kbcxqa9rsmqpq",
                "in": "User:kabira",
                "out": "Card:rakuten"
            }
        ]
    },
    {
        "time": "111.018µs",
        "status": "OK",
        "result": [
            {
                "id": "owner:y8s3eychfra7h0ve5fyo",
                "in": "Card:rakuten",
                "out": "User:kabira"
            }
        ]
    }
]
```
:::


## O2O Same Type
![o2oSame](https://entgo.io/images/assets/er_linked_list.png)
この例ではLinkedListを実装しています．Nodeは`next`と`prev`という再帰的なエッジを持ち，全てのNodeの`next`の先には必ず一つのNodeがあり，`prev`もまた同様です．
ここでは丸ノ内線分岐線（方南町支線）の各駅をLinkedListとみなしてクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE Node:1 SET
    value = '中野新橋駅'
;
CREATE Node:2 SET
    value = '中野富士見町駅'
;
CREATE Node:3 SET
    value = '方南町駅'
;
RELATE Node:1->next->Node:2;
RELATE Node:2->next->Node:3;
RELATE Node:3->next->Node:1;
RELATE Node:1->prev->Node:3;
RELATE Node:2->prev->Node:1;
RELATE Node:3->prev->Node:2;
```
:::details 結果
```json
[
    {
        "time": "335.283µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:1",
                "value": "中野新橋駅"
            }
        ]
    },
    {
        "time": "61.776µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:2",
                "value": "中野富士見町駅"
            }
        ]
    },
    {
        "time": "46.888µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:3",
                "value": "方南町駅"
            }
        ]
    },
    {
        "time": "152.059µs",
        "status": "OK",
        "result": [
            {
                "id": "next:3f9hmd53kq7r962ti23j",
                "in": "Node:1",
                "out": "Node:2"
            }
        ]
    },
    {
        "time": "188.184µs",
        "status": "OK",
        "result": [
            {
                "id": "next:p7ur7tms5e0ln5dkqk4e",
                "in": "Node:2",
                "out": "Node:3"
            }
        ]
    },
    {
        "time": "138.964µs",
        "status": "OK",
        "result": [
            {
                "id": "next:m3bnhvi33b44ykz2x5l0",
                "in": "Node:3",
                "out": "Node:1"
            }
        ]
    },
    {
        "time": "200.914µs",
        "status": "OK",
        "result": [
            {
                "id": "prev:3a6j3iyabwj9lybf0y9k",
                "in": "Node:1",
                "out": "Node:3"
            }
        ]
    },
    {
        "time": "88.638µs",
        "status": "OK",
        "result": [
            {
                "id": "prev:0dd8xybtkwm439wnpuwn",
                "in": "Node:2",
                "out": "Node:1"
            }
        ]
    },
    {
        "time": "117.515µs",
        "status": "OK",
        "result": [
            {
                "id": "prev:bpeie0hw04b1amrdohn8",
                "in": "Node:3",
                "out": "Node:2"
            }
        ]
    }
]
```
:::

## O2O Bidirectional
![o2o Bi](https://entgo.io/images/assets/er_user_spouse.png)
この例では，Userそれ自身がspouse(=配偶者)というエッジで双方向的に遷移します．全てのUserはたった1人の配偶者を持ちます．多くの社会でそうであるように重婚は認められません．
ここでは日本中にその名を轟かせた元ロイヤルファミリーをクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE User:kei SET
    age = 31,
    name = '小室圭'
;
CREATE User:mako SET
    age = 31,
    name = '小室眞子'
;
RELATE User:mako->spouse->User:kei;
RELATE User:kei->spouse->User:mako;
```
:::details 結果
```json
[
    {
        "time": "635.726µs",
        "status": "OK",
        "result": [
            {
                "age": 31,
                "id": "User:kei",
                "name": "小室圭"
            }
        ]
    },
    {
        "time": "68.989µs",
        "status": "OK",
        "result": [
            {
                "age": 31,
                "id": "User:mako",
                "name": "小室眞子"
            }
        ]
    },
    {
        "time": "128.022µs",
        "status": "OK",
        "result": [
            {
                "id": "spouse:oa4jbxk0kwzwlisjjs3o",
                "in": "User:mako",
                "out": "User:kei"
            }
        ]
    },
    {
        "time": "90.83µs",
        "status": "OK",
        "result": [
            {
                "id": "spouse:5xxy3y7ltfi9a5bh0037",
                "in": "User:kei",
                "out": "User:mako"
            }
        ]
    }
]
```
:::

## O2M Two Types
![o2m Two](https://entgo.io/images/assets/er_user_pets.png)
冒頭の例ですが再掲します．Userは多くのPetを飼うことができますが，Petは1人のUserしか持つことができません．
ここでは私がポチとタマを飼っている例をクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE User:Me;
CREATE Pet:Pochi;
CREATE Pet:Tama;
LET $pet = (SELECT id FROM Pet);
RELATE User:Me->pets->$pet;
RELATE User:Me<-owner<-$pet;
```
:::details 結果
```json
[
    {
        "time": "364.184µs",
        "status": "OK",
        "result": [
            {
                "id": "User:Me"
            }
        ]
    },
    {
        "time": "75.402µs",
        "status": "OK",
        "result": [
            {
                "id": "Pet:Pochi"
            }
        ]
    },
    {
        "time": "60.105µs",
        "status": "OK",
        "result": [
            {
                "id": "Pet:Tama"
            }
        ]
    },
    {
        "time": "82.535µs",
        "status": "OK",
        "result": null
    },
    {
        "time": "151.585µs",
        "status": "OK",
        "result": [
            {
                "id": "pets:cdnuvvkei4bin0yja6da",
                "in": "User:Me",
                "out": "Pet:Pochi"
            },
            {
                "id": "pets:u3lvmdb5aqkkwhi39yxj",
                "in": "User:Me",
                "out": "Pet:Tama"
            }
        ]
    },
    {
        "time": "139.369µs",
        "status": "OK",
        "result": [
            {
                "id": "owner:j762foq67x2746hpgfk4",
                "in": "Pet:Pochi",
                "out": "User:Me"
            },
            {
                "id": "owner:32lx0cz6ceopdfijmtex",
                "in": "Pet:Tama",
                "out": "User:Me"
            }
        ]
    }
]
```
:::

## O2M Same Type
![o2m Same](https://entgo.io/images/assets/er_tree.png)
この例は，木構造になります．Nodeは`parent`と`children`という再帰的なエッジを持ち，全てのNodeの`children`の先には複数の(子)Nodeがあり，逆に`prev`の先には必ず1人の(親)Nodeがあります．
ここでは現ロイヤルファミリーをクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE Node:Akihito SET
    value = '明仁'
;
CREATE Node:Naruhito SET
    value = '徳仁'
;
CREATE Node:Humihito SET
    value = '文仁'
;
CREATE Node:Aiko SET
    value = '愛子'
;
CREATE Node:Kako SET
    value = '佳子'
;
CREATE Node:Hisahito SET
    value = '悠仁'
;
RELATE Node:Akihito->children->Node:Naruhito;
RELATE Node:Akihito->children->Node:Humihito;
RELATE Node:Naruhito->children->Node:Aiko;
RELATE Node:Humihito->children->Node:Kako;
RELATE Node:Humihito->children->Node:Hisahito;
RELATE Node:Naruhito->parent->Node:Akihito;
RELATE Node:Humihito->parent->Node:Akihito;
RELATE Node:Aiko->children->Node:Naruhito;
RELATE Node:Kako->children->Node:Humihito;
RELATE Node:Hisahito->children->Node:Humihito;
```
:::details 結果
```json
[
    {
        "time": "642.419µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Akihito",
                "value": "明仁"
            }
        ]
    },
    {
        "time": "67.458µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Naruhito",
                "value": "徳仁"
            }
        ]
    },
    {
        "time": "48.643µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Humihito",
                "value": "文仁"
            }
        ]
    },
    {
        "time": "48.54µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Aiko",
                "value": "愛子"
            }
        ]
    },
    {
        "time": "43.734µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Kako",
                "value": "佳子"
            }
        ]
    },
    {
        "time": "44.215µs",
        "status": "OK",
        "result": [
            {
                "id": "Node:Hisahito",
                "value": "悠仁"
            }
        ]
    },
    {
        "time": "130.449µs",
        "status": "OK",
        "result": [
            {
                "id": "children:ahltua21iuh31mb2stl2",
                "in": "Node:Akihito",
                "out": "Node:Naruhito"
            }
        ]
    },
    {
        "time": "100.64µs",
        "status": "OK",
        "result": [
            {
                "id": "children:fvu4mtoi5329595f2cf6",
                "in": "Node:Akihito",
                "out": "Node:Humihito"
            }
        ]
    },
    {
        "time": "80.036µs",
        "status": "OK",
        "result": [
            {
                "id": "children:hzxzv2say4gg4vloi600",
                "in": "Node:Naruhito",
                "out": "Node:Aiko"
            }
        ]
    },
    {
        "time": "69.371µs",
        "status": "OK",
        "result": [
            {
                "id": "children:h3hj7hkn9dafbu8orqxa",
                "in": "Node:Humihito",
                "out": "Node:Kako"
            }
        ]
    },
    {
        "time": "79.089µs",
        "status": "OK",
        "result": [
            {
                "id": "children:vkmp23q9w5f0w4fdfoy5",
                "in": "Node:Humihito",
                "out": "Node:Hisahito"
            }
        ]
    },
    {
        "time": "93.963µs",
        "status": "OK",
        "result": [
            {
                "id": "parent:npqjhb20m5e8na3n1fd3",
                "in": "Node:Naruhito",
                "out": "Node:Akihito"
            }
        ]
    },
    {
        "time": "70.019µs",
        "status": "OK",
        "result": [
            {
                "id": "parent:050ynsx568w7t4uqfq95",
                "in": "Node:Humihito",
                "out": "Node:Akihito"
            }
        ]
    },
    {
        "time": "69.556µs",
        "status": "OK",
        "result": [
            {
                "id": "children:87i2qq2dj4p7ivpc6bvt",
                "in": "Node:Aiko",
                "out": "Node:Naruhito"
            }
        ]
    },
    {
        "time": "62.241µs",
        "status": "OK",
        "result": [
            {
                "id": "children:0bm8u7mlvzln5723xmnv",
                "in": "Node:Kako",
                "out": "Node:Humihito"
            }
        ]
    },
    {
        "time": "61.602µs",
        "status": "OK",
        "result": [
            {
                "id": "children:l1ormfpueftikefgesyj",
                "in": "Node:Hisahito",
                "out": "Node:Humihito"
            }
        ]
    }
]
```
:::

## M2M Two Types
![m2m Two](https://entgo.io/images/assets/er_user_groups.png)
冒頭の例ですが再掲します．Groupには多くのUserが所属しており，またUserは複数のGroupを掛け持ちできる構造です．
ここでは太郎，次郎，花子のそれぞれが野球部，サッカー部，軽音部に入ります．次郎はサッカー部と軽音部を兼部しており，軽音部には次郎と花子が所属している例をクエリしてみます．

クエリ例(SurrealDB)
```sql
CREATE User:taro SET
    name = '太郎'
;
CREATE User:jiro SET
    name = '次郎'
;
CREATE User:hanako SET
    name = '花子'
;
CREATE Group:baseball SET
    name = '野球部'
;
CREATE Group:football SET
    name = 'サッカー部'
;
CREATE Group:band SET
    name = '軽音部'
;
RELATE Group:baseball->users->User:taro;
RELATE Group:football->users->User:jiro;
RELATE Group:band->users->User:jiro;
RELATE Group:band->users->User:hanako;
RELATE User:tako->groups->Group:baseball;
RELATE User:jiro->groups->Group:football;
RELATE User:jiro->groups->Group:band;
RELATE User:hanako->groups->Group:hanako;
```
:::details 結果
```json
[
    {
        "time": "1.193261ms",
        "status": "OK",
        "result": [
            {
                "id": "User:taro",
                "name": "太郎"
            }
        ]
    },
    {
        "time": "168.7µs",
        "status": "OK",
        "result": [
            {
                "id": "User:jiro",
                "name": "次郎"
            }
        ]
    },
    {
        "time": "57.888µs",
        "status": "OK",
        "result": [
            {
                "id": "User:hanako",
                "name": "花子"
            }
        ]
    },
    {
        "time": "109.236µs",
        "status": "OK",
        "result": [
            {
                "id": "Group:baseball",
                "name": "野球部"
            }
        ]
    },
    {
        "time": "76.874µs",
        "status": "OK",
        "result": [
            {
                "id": "Group:football",
                "name": "サッカー部"
            }
        ]
    },
    {
        "time": "58.479µs",
        "status": "OK",
        "result": [
            {
                "id": "Group:band",
                "name": "軽音部"
            }
        ]
    },
    {
        "time": "278.187µs",
        "status": "OK",
        "result": [
            {
                "id": "users:dj8lb0sja1up8dqao6cp",
                "in": "Group:baseball",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "233.356µs",
        "status": "OK",
        "result": [
            {
                "id": "users:xd4rgokq42gr5wisgnme",
                "in": "Group:football",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "257.404µs",
        "status": "OK",
        "result": [
            {
                "id": "users:6p158br703hrupkcpgv7",
                "in": "Group:band",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "146.283µs",
        "status": "OK",
        "result": [
            {
                "id": "users:fztkobvbzhu7hqd1f2m6",
                "in": "Group:band",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "195.443µs",
        "status": "OK",
        "result": [
            {
                "id": "groups:znsfiwyjw6tz2x3urbg5",
                "in": "User:tako",
                "out": "Group:baseball"
            }
        ]
    },
    {
        "time": "138.745µs",
        "status": "OK",
        "result": [
            {
                "id": "groups:uha8bk54budzyz6anktk",
                "in": "User:jiro",
                "out": "Group:football"
            }
        ]
    },
    {
        "time": "74.115µs",
        "status": "OK",
        "result": [
            {
                "id": "groups:bjcz6zl2n6twhkns6lvo",
                "in": "User:jiro",
                "out": "Group:band"
            }
        ]
    },
    {
        "time": "111.826µs",
        "status": "OK",
        "result": [
            {
                "id": "groups:cwrxztn03m2cedivv3xy",
                "in": "User:hanako",
                "out": "Group:hanako"
            }
        ]
    }
]
```
:::

## M2M Same Type
![m2m Same](https://entgo.io/images/assets/er_following_followers.png)
各Userはフォロワーとフォロイーを持ちます．`followers`がフォロワーを，`following`がフォロイーを示します．

グラフネットワークといえば真っ先に思い浮かぶのがこの構造ではないでしょうか．[ユーザーローカルがTwitterで拡散経路を可視化する「リツイート分析ツール」を公開](https://gaiax-socialmedialab.jp/post-1691/)
![retweet network](https://gaiax-socialmedialab.jp/wp-content/uploads/2-1.png)
先程の太郎，次郎，花子がTwitterをしています．次郎は兼部しているので太郎と花子を両方相互フォローしています．太郎は何となく花子が気になるのでフォローしていますが，所詮は片想いに過ぎない様子をクエリします．

クエリ例(SurrealDB)
```sql
CREATE User:taro SET
    age = 17,
    name = '太郎'
;
CREATE User:jiro SET
    age = 16,
    name = '次郎'
;
CREATE User:hanako SET
    age = 15,
    name = '花子'
;
RELATE User:taro->following->User:hanako;
RELATE User:taro->following->User:jiro;
RELATE User:jiro->following->User:taro;
RELATE User:jiro->following->User:hanako;
RELATE User:hanako->following->User:jiro;
RELATE User:taro->followers->User:jiro;
RELATE User:jiro->followers->User:taro;
RELATE User:jiro->followers->User:hanako;
RELATE User:hanako->followers->User:taro;
RELATE User:hanako->followers->User:jiro;
```
:::details 結果
```json
[
    {
        "time": "426.801µs",
        "status": "OK",
        "result": [
            {
                "age": 17,
                "id": "User:taro",
                "name": "太郎"
            }
        ]
    },
    {
        "time": "86.937µs",
        "status": "OK",
        "result": [
            {
                "age": 16,
                "id": "User:jiro",
                "name": "次郎"
            }
        ]
    },
    {
        "time": "55.949µs",
        "status": "OK",
        "result": [
            {
                "age": 15,
                "id": "User:hanako",
                "name": "花子"
            }
        ]
    },
    {
        "time": "239.015µs",
        "status": "OK",
        "result": [
            {
                "id": "following:2by2qpym2c4u5740uqf1",
                "in": "User:taro",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "90.022µs",
        "status": "OK",
        "result": [
            {
                "id": "following:4lc5yrbw4fa67y6cuy1b",
                "in": "User:taro",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "86.07µs",
        "status": "OK",
        "result": [
            {
                "id": "following:4u2bwt2yd2n2lnn0uven",
                "in": "User:jiro",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "127.986µs",
        "status": "OK",
        "result": [
            {
                "id": "following:t6r1u05phrhq0caz6k1q",
                "in": "User:jiro",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "77.653µs",
        "status": "OK",
        "result": [
            {
                "id": "following:0lwj6dsrbnm2laehm72y",
                "in": "User:hanako",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "174.444µs",
        "status": "OK",
        "result": [
            {
                "id": "followers:r9ttsdaruroj56lthzew",
                "in": "User:taro",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "202.269µs",
        "status": "OK",
        "result": [
            {
                "id": "followers:e4aegdde24gt2am1rats",
                "in": "User:jiro",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "83.723µs",
        "status": "OK",
        "result": [
            {
                "id": "followers:2sk3in7uvqhlb9f2d76g",
                "in": "User:jiro",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "70.984µs",
        "status": "OK",
        "result": [
            {
                "id": "followers:y0nbv045di9rb3g5nc2c",
                "in": "User:hanako",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "78.756µs",
        "status": "OK",
        "result": [
            {
                "id": "followers:i65wkncgo7o8iiwb5wvs",
                "in": "User:hanako",
                "out": "User:jiro"
            }
        ]
    }
]
```
:::

## M2M Bidirectional
![m2m Bi](https://entgo.io/images/assets/er_user_friends.png)
各Userが持つ`friends`はUserを複数，お互いに持てる対称で平等な関係性です．これをトモダチと言います．
互いに友達である太郎，次郎，花子の様子をクエリします．

クエリ例(SurrealDB)
```sql
CREATE User:taro SET
    age = 17,
    name = '太郎'
;
CREATE User:jiro SET
    age = 16,
    name = '次郎'
;
CREATE User:hanako SET
    age = 15,
    name = '花子'
;
RELATE User:taro->friends->User:jiro;
RELATE User:taro->friends->User:hanako;
RELATE User:jiro->friends->User:taro;
RELATE User:jiro->friends->User:hanako;
RELATE User:hanako->friends->User:taro;
RELATE User:hanako->friends->User:jiro;
```
:::details 結果
```json
[
    {
        "time": "659.251µs",
        "status": "OK",
        "result": [
            {
                "age": 17,
                "id": "User:taro",
                "name": "太郎"
            }
        ]
    },
    {
        "time": "86.009µs",
        "status": "OK",
        "result": [
            {
                "age": 16,
                "id": "User:jiro",
                "name": "次郎"
            }
        ]
    },
    {
        "time": "56.47µs",
        "status": "OK",
        "result": [
            {
                "age": 15,
                "id": "User:hanako",
                "name": "花子"
            }
        ]
    },
    {
        "time": "327.108µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:2ojtwn4logxxo6gj2z2l",
                "in": "User:taro",
                "out": "User:jiro"
            }
        ]
    },
    {
        "time": "182.621µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:4ckm42inqzc6bhccup6b",
                "in": "User:taro",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "224.32µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:mwha2vsgbs3zb4a4z8f9",
                "in": "User:jiro",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "148.636µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:ienrjxu14t1k4bekkn3x",
                "in": "User:jiro",
                "out": "User:hanako"
            }
        ]
    },
    {
        "time": "121.744µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:2ovhjy2cpa65rfmvntr7",
                "in": "User:hanako",
                "out": "User:taro"
            }
        ]
    },
    {
        "time": "178.521µs",
        "status": "OK",
        "result": [
            {
                "id": "friends:mlnsju5n43mywqliwagu",
                "in": "User:hanako",
                "out": "User:jiro"
            }
        ]
    }
]
```
:::

# まとめ
エンティティ間の関係性（リレーションシップ）であるところのエッジをデータ構造で網羅的に分類し，クエリ例を記載しました．関係性は上記のいずれかであるはずなので，対象がどの構造か見極めて設計時に役立てて貰えれば嬉しいです．
また間違いがあればコメントで指摘いただけると幸いです．

# Reference
 - [Edges - entgo.io](https://entgo.io/ja/docs/schema-edges)
ほぼこのドキュメントをお借りしました
 - [グラフデータベースとは何か　～ネットワーク状のデータ構造から瞬時に情報を検索するDBを解説](https://www.imagazine.co.jp/12805-2/)