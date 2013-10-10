module gamemain;

import ball;
import stick;
import mapobject;

import std.stdio;
import std.string;
import std.windows.charset;
import DX_lib;
import convert;

//マップ上のオブジェクトの性質
enum NatureObject{
	OBJ_SPACE,
	OBJ_BLOCK,
	OBJ_UNKNOWN,
};

//ゲームの状態
enum mode {
	TITLE,
	NEWGAME,
	MOVEINPUT,
	MISS,
	GAME_OVER,
	STAGE_CLEAR,
	GAME_CLEAR,
};

class GameMain {

	//ゲームで使用する各種定数
	const int stageHeight = 32; //マップの高さ
	const int stageWidth = 11; //マップの横幅
	const int ballInitialCoordinateX = 250; //ボールの初期座標（x軸）
	const int ballInitialCoordinateY = 400; //ボールの初期座標（y軸）
	const int ballWidth = 15; //ボールの横幅
	const real InitialAngle = 45; //ボールの初期角度
	const int stickInitialCoordinateX = 190; //スティックの初期座標（x軸）
	const int stickInitialCoordinateY = 440; //スティックの初期座標（y軸）
	const int stickSpeed = 4; //スティックが移動するスピード
	const int mapObjectHeight = 15; //ブロックの高さ
	const int mapObjectWidth = 40; //ブロックの横幅
	const int locationOfWall = 441; //壁の配置場所
	const int stageTotalNumber = 5; //ゲームのステージの総数

	//ゲームで使用する各種変数
	mode gameMode; //ゲームの状態を表す
	int[] key; // キーが押されているフレーム数を格納する
	MapObject[stageWidth][stageHeight] stageMap; //ステージのマップ
	int currentStageNumber; //現在のステージ数
	int life = 5; //スティックの残機数

	//スティックとボール
	Stick stick;
	Ball ball;

	//フォントの色とフォントの指定
	int fontType = 0;
	int white = 0;

	//ゲームのキャラクター
	int stickbuf = 0;
	int ballbuf = 0;
	int wallbuf = 0;
	int blockbuf = 0;

	//コンストラクタ
	this() {
		//変数の初期化
		this.key = new int[256];
		this.gameMode = mode.TITLE; //ゲームモードをゲームの新規開始にする

		//フォントの色とフォントの指定（ゲームクリア時に使用）
		this.fontType = dx_CreateFontToHandle(null, 64, 5, -1);
		this.white = dx_GetColor(255, 255, 255);

		//画面のキャラクターを読み込む
		this.stickbuf = dx_LoadGraph(cast(char*)"gamedata\\stick.png");
		this.ballbuf = dx_LoadGraph(cast(char*)"gamedata\\ball.png");
		this.wallbuf = dx_LoadGraph(cast(char*)"gamedata\\wall.png");
		this.blockbuf = dx_LoadGraph(cast(char*)"gamedata\\block.png");

		//ボールとスティックを作る
		this.ball = new Ball;
		this.stick = new Stick;
	}

	//タイトル画面の作成と表示
	public void showTitleScreenDraw() {

		byte[] tmpKey = new byte[256]; // 現在のキーの入力状態を格納する

		string titleStr = format("Breakout");
		titleStr = convertsMultibyteStringOfUtf(titleStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(180, 100, cast(char*)toStringz(titleStr), white, fontType);

		//Enterキー入力待ちのメッセージ
		dx_DrawString(200, 300, cast(char*)toStringz("Please Press the Enter key"), white);

		//全てのキーの入力状態を得る
		dx_GetHitKeyStateAll(cast(byte*)tmpKey);

		//Enterキーが押された場合
		if (tmpKey[KEY_INPUT_RETURN] == 1) {
			this.gameMode = mode.NEWGAME;
		}

		return;
	}

	//ゲームの開始準備
	public void gameInitialize() {

		//マップをファイルから読み込む
		this.stageInitialize("gamedata\\stage1.txt");

		//ゲームの初期化処理が終わった為、ゲーム本編の画面に移動する
		gameMode = mode.MOVEINPUT;

		//現在のステージ数を初期化
		currentStageNumber = 1;

		//ボールとスティックを初期配置場所に配置し、ボールの角度を初期化する
		this.ball.setX(ballInitialCoordinateX);
		this.ball.setY(ballInitialCoordinateY);
		this.ball.setAngle(InitialAngle);

		this.stick.setX(stickInitialCoordinateX);
		this.stick.setY(stickInitialCoordinateY);

		return;
	}

	//マップの読み込みと初期化
	private void stageInitialize(string fileName) {

		char[stageWidth][stageHeight] tempStageMap; //ファイルから読み込んだマップ

		//ファイルを読み込む
		auto fp = File(fileName, "r");

		for (int i= 0; i < stageHeight; i++) {

			char[] line;
			fp.readln(line);

			for (int j= 0; j < stageWidth; j++) {
				tempStageMap[i][j] = line[j];
			}
		}

		//ファイルから読み込んだマップをゲーム内部のマップに変換する
		for (int i= 0; i < stageHeight; i++) {

			for (int j= 0; j < stageWidth; j++) {

				switch(tempStageMap[i][j]) {
					case '#':
						MapObject mapObject = new MapObject;
						NatureObject natureObject = NatureObject.OBJ_BLOCK;
						mapObject.setNatureObject(natureObject);
						stageMap[i][j] = mapObject;
						break;
					case '.':
						MapObject mapObject = new MapObject;
						NatureObject natureObject = NatureObject.OBJ_SPACE;
						mapObject.setNatureObject(natureObject);
						stageMap[i][j] = mapObject;
						break;
					default:
						MapObject mapObject = new MapObject;
						NatureObject natureObject = NatureObject.OBJ_UNKNOWN;
						mapObject.setNatureObject(natureObject);
						stageMap[i][j] = mapObject;
						break;
				}
			}
		}

		//マップのオブジェクトの座標を設定する
		for (int i= 0; i < stageHeight; i++) {

			for (int j= 0; j < stageWidth; j++) {
				switch(stageMap[i][j].getNatureObject()) {
					case NatureObject.OBJ_BLOCK:
						stageMap[i][j].setX(j * mapObjectWidth);
						stageMap[i][j].setY(i * mapObjectHeight);
						break;
					case NatureObject.OBJ_SPACE:
						stageMap[i][j].setX(j * mapObjectWidth);
						stageMap[i][j].setY(i * mapObjectHeight);
						break;
					case NatureObject.OBJ_UNKNOWN:
						stageMap[i][j].setX(j * mapObjectWidth);
						stageMap[i][j].setY(i * mapObjectHeight);
						break;
					default:
						break;
				}
			}
		}

		return;
	}

	//ゲーム内部の計算フェーズ
	public void calc() {

		//ゲームのクリアチェック
		if (this.checkClear()) {
			//フラグを更新し、ゲームのクリア画面へ移動
			gameMode = mode.STAGE_CLEAR;
			return;
		}

		//ゲーム内部の更新処理
		this.upDate();

		return;
	}

	//ゲームのクリアチェック
	private bool checkClear() {
		//画面上にブロックが無ければ、クリアしている
		for (int i= 0; i < stageHeight; i++) {
			for (int j= 0; j < stageWidth; j++) {
				if (stageMap[i][j].getNatureObject() == NatureObject.OBJ_BLOCK) {
					return false;
				}
			}
		}

		return true;
	}

	//ゲームのアップデート処理
	private void upDate() {

		//ユーザーの入力を取得
		byte[] tmpKey = new byte[256]; // 現在のキーの入力状態を格納する
		dx_GetHitKeyStateAll(cast(byte*)tmpKey); // 全てのキーの入力状態を得る

		//スティックの移動
		if (tmpKey[KEY_INPUT_RIGHT] == 1) { //右キーが押された
			int x = stick.getX();
			x += stickSpeed;
			stick.setX(x);
		}

		if (tmpKey[KEY_INPUT_LEFT] == 1) { //左キーが押された
			int x = stick.getX();
			x += -stickSpeed;
			stick.setX(x);
		}

		//スティックが右端に来た時
		if (stick.getRightEnd() > locationOfWall) {
			stick.setX(365);
		}

		//スティックが左端に来た時
		if (stick.getX() < 0) {
			stick.setX(0);
		}

		//ボールの移動
		ball.move();

		//ボールの反射（天井）
		if (ball.getY() < 0) {
			real angle = ball.getAngle();
			ball.setAngle(-angle);
		}

		//ボールの反射（右壁）
		if (ball.getX() + ballWidth > locationOfWall) {
			real angle = ball.getAngle();
			real angleOfReflection = (2 * 90) - angle; //反射角を求める
			ball.setAngle(angleOfReflection);
		}

		//ボールの反射（左壁）
		if (ball.getX() < 0) {
			real angle = ball.getAngle();
			real angleOfReflection = (2 * 90) - angle; //反射角を求める
			ball.setAngle(angleOfReflection);
		}

		//ミスの処理。残機を減らし、ミスした際の画面へ移動
		if (ball.getY() > 480) {
			this.gameMode = mode.MISS;
			life--;
			return;
		}

		//ボールの反射（スティック）
		stick.ballCollisionCheck(this.ball);

		//マップ上にある全てのオブジェクトとボールの現在座標を比較し、
		//ブロックの矩形にボールが侵入していたら、ブロックを消去する
		for (int i= 0; i < stageHeight; i++) {
			for (int j= 0; j < stageWidth; j++) {
				switch(stageMap[i][j].getNatureObject()) {
					case NatureObject.OBJ_BLOCK:
						stageMap[i][j].ballCollisionCheck(this.ball);
						break;
					default:
						break;
				}
			}
		}

		return;
	}

	//ゲーム画面の描画フェーズ
	public void gameMainScreenDraw() {

		//ゲームの説明等の表示
		string stageStr = format("STAGE %d", currentStageNumber);
		stageStr = convertsMultibyteStringOfUtf(stageStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(480, 50, cast(char*)toStringz(stageStr), white);

		string messageStr = "Please input key";
		messageStr = convertsMultibyteStringOfUtf(messageStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(480, 80, cast(char*)toStringz(messageStr), white);

		string rightLeftStr = "←　→";
		rightLeftStr = convertsMultibyteStringOfUtf(rightLeftStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(480, 110, cast(char*)toStringz(rightLeftStr), white);

		string lifeStr = format("LIFE : %d", life);
		lifeStr = convertsMultibyteStringOfUtf(lifeStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(480, 140, cast(char*)toStringz(lifeStr), white);

		//壁を表示させる
		for (int i = 0; i < 480; i++) {
			dx_DrawGraph(locationOfWall, i, wallbuf, true);
		}

		//マップの配置通りにグラフィックを描画する
		for (int i= 0; i < stageHeight; i++) {
			for (int j= 0; j < stageWidth; j++) {
				switch(stageMap[i][j].getNatureObject()) {
					case NatureObject.OBJ_BLOCK:
						dx_DrawGraph(j * mapObjectWidth, i * mapObjectHeight, blockbuf, true);
						break;
					default:
						break;
				}
			}
		}

		//スティックとボールを描画する
		dx_DrawGraph(stick.getX(), stick.getY(), stickbuf, true);
		dx_DrawGraph(cast(int)ball.getX(), cast(int)ball.getY(), ballbuf, true);

		return;
	}

	//ミスした際の画面の描画フェーズ
	public void missScreenDraw() {

		//残機が0になったら、ゲームオーバーの処理に移る
		if (life == 0) {
			this.gameMode = mode.GAME_OVER;
			return;
		}

		//ステージクリア画面の表示
		string stageStr = format("ｍｉｓｓ！！");
		stageStr = convertsMultibyteStringOfUtf(stageStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(29, 179, cast(char*)toStringz(stageStr), white, fontType);

		//Enterキー入力待ちのメッセージ
		string enterMessageStr = format("Please Press the Enter key");
		enterMessageStr = convertsMultibyteStringOfUtf(enterMessageStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(120, 300, cast(char*)toStringz(enterMessageStr), white);

		//ここにEnterキーを押したら、次のステージのマップを生成し、新しいステージを始める処理を書く
		byte[] tmpKey = new byte[256]; // 現在のキーの入力状態を格納する
		dx_GetHitKeyStateAll(cast(byte*)tmpKey); // 全てのキーの入力状態を得る

		//Enterキーが押された場合
		if (tmpKey[KEY_INPUT_RETURN] == 1) {

			//ボールとスティックを初期配置場所に配置し、ボールの角度を初期化する
			this.ball.setX(ballInitialCoordinateX);
			this.ball.setY(ballInitialCoordinateY);
			this.ball.setAngle(InitialAngle);

			this.stick.setX(stickInitialCoordinateX);
			this.stick.setY(stickInitialCoordinateY);

			this.gameMode = mode.MOVEINPUT;
		}

		return;
	}

	//ゲームオーバー画面の表示
	public void gameOverScreenDraw() {

		//ゲームオーバー画面の表示
		string gameStr = format(" ＧＡＭＥ");
		gameStr = convertsMultibyteStringOfUtf(gameStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(40, 179, cast(char*)toStringz(gameStr), white, fontType);

		string clearStr = format("ＯＶＥＲ！");
		clearStr = convertsMultibyteStringOfUtf(clearStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(40, 229, cast(char*)toStringz(clearStr), white, fontType);

		//Enterキー入力待ちのメッセージ
		string enterMessageStr = format("Please Press the Enter key");
		enterMessageStr = convertsMultibyteStringOfUtf(enterMessageStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawString(120, 300, cast(char*)toStringz(enterMessageStr), white);

		//ここにEnterキーを押したら、次のステージのマップを生成し、新しいステージを始める処理を書く
		byte[] tmpKey = new byte[256]; // 現在のキーの入力状態を格納する
		dx_GetHitKeyStateAll(cast(byte*)tmpKey); // 全てのキーの入力状態を得る

		//Enterキーが押された場合
		if (tmpKey[KEY_INPUT_RETURN] == 1) {
			life = 5; //自機の数を元に戻す
			this.gameMode = mode.TITLE;
		}

		return;
	}

	//ステージクリア画面の描画フェーズ
	public void stageClearScreenDraw() {

		//クリアしたステージが規定のステージ数を超えたら、ゲームはクリアした状態になる
		if (currentStageNumber == stageTotalNumber) {
			this.gameMode = mode.GAME_CLEAR;
			return;
		}

		//クリアしたステージ数が規定の数に達しなければ、次のステージに進む
		if (currentStageNumber < stageTotalNumber) {

			//ステージクリア画面の表示
			string stageStr = format(" ＳＴＡＧＥ");
			stageStr = convertsMultibyteStringOfUtf(stageStr); //文字列をUTF-8からマルチバイト文字列に変換する
			dx_DrawStringToHandle(29, 179, cast(char*)toStringz(stageStr), white, fontType);

			string clearStr = format("ＣＬＥＡＲ！");
			clearStr = convertsMultibyteStringOfUtf(clearStr); //文字列をUTF-8からマルチバイト文字列に変換する
			dx_DrawStringToHandle(29, 229, cast(char*)toStringz(clearStr), white, fontType);

			//Enterキー入力待ちのメッセージ
			string enterMessageStr = format("Please Press the Enter key");
			enterMessageStr = convertsMultibyteStringOfUtf(enterMessageStr); //文字列をUTF-8からマルチバイト文字列に変換する
			dx_DrawString(120, 300, cast(char*)toStringz(enterMessageStr), white);

			//ここにEnterキーを押したら、次のステージのマップを生成し、新しいステージを始める処理を書く
			byte[] tmpKey = new byte[256]; // 現在のキーの入力状態を格納する
			dx_GetHitKeyStateAll(cast(byte*)tmpKey); // 全てのキーの入力状態を得る

			//Enterキーが押された場合
			if (tmpKey[KEY_INPUT_RETURN] == 1) {

				//現在のステージを更新
				this.currentStageNumber++;

				//新しいマップを読み込む
				string fileName = format("gamedata\\stage%d.txt", currentStageNumber);

				//マップをファイルから読み込む
				this.stageInitialize(fileName);

				//ボールとスティックを初期配置場所に配置し、ボールの角度を初期化する
				this.ball.setX(ballInitialCoordinateX);
				this.ball.setY(ballInitialCoordinateY);
				this.ball.setAngle(InitialAngle);

				this.stick.setX(stickInitialCoordinateX);
				this.stick.setY(stickInitialCoordinateY);

				this.gameMode = mode.MOVEINPUT;
			}
		}

		return;
	}

	//ステージクリア画面の描画フェーズ
	public void gameClearScreenDraw() {

		//ゲームクリア画面の表示
		string gameStr = format("ＧＡＭＥ");
		gameStr = convertsMultibyteStringOfUtf(gameStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(29, 179, cast(char*)toStringz(gameStr), white, fontType);

		string clearStr = format("ＣＬＥＡＲ！");
		clearStr = convertsMultibyteStringOfUtf(clearStr); //文字列をUTF-8からマルチバイト文字列に変換する
		dx_DrawStringToHandle(29, 229, cast(char*)toStringz(clearStr), white, fontType);

		return;
	}
}