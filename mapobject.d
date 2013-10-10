module mapobject;

import ball;
import gamemain;

class MapObject {

	int x; //ブロックの座標
	int y; //ブロックの座標
	const int mapObjectHeight = 15; //ブロックの高さ
	const int mapObjectWidth = 40; //ブロックの横幅
	NatureObject natureObject; //オブジェクトの性質

	this() {
	}

	int getX() {
		return this.x;
	}

	void setX(int x) {
		this.x = x;
	}

	int getY() {
		return this.y;
	}

	void setY(int y) {
		this.y = y;
	}

	NatureObject getNatureObject() {
		return this.natureObject;
	}

	void setNatureObject(NatureObject natureObject) {
		this.natureObject = natureObject;
	}

	//ボールがブロックに衝突しているかをチェックする
	void ballCollisionCheck(ref Ball ball) {

		bool collisionFlag = false; //trueならブロックとボールは衝突している

		if (NatureObject.OBJ_BLOCK == this.natureObject) {

			//ボールの座標がブロックの矩形に重なっていないかをチェックする
			
			//ボールのX座標がオブジェクトの矩形より大きく、ボールのX座標が矩形のX座標の幅よりも小さい場合、
			//または矩形のX座標がボールのX座標よりも大きく、かつ、矩形のX座標よりもボールのX座標がボールの横幅よりも大きい場合、
			//かつ、ボールのY座標が矩形のY座標よりも大きく、ボールのY座標が矩形のY座標の高さよりも大きい場合、
			//または矩形のY座標がボールのY座標よりも大きく、さらに矩形のY座標よりもボールのY座標がボールの縦幅よりも大きい場合、
			if (((ball.getX() > this.x) && (ball.getX() < (this.x + this.mapObjectWidth)) ||
				(this.x > ball.getX()) && (this.x < (ball.getX() + ball.getBallWidth()))) &&
				((ball.getY() > this.y) && (ball.getY() < (this.y + this.mapObjectHeight)) ||
				(this.y > ball.getY()) && (this.y < (ball.getY() + ball.getBallHeight()))))
			{
				//ブロックの矩形と座標が重なっていたら、ボールを反射させる
				real angle = ball.getAngle();
				ball.setAngle(-angle);
				collisionFlag = true;
			}

			//ブロックを消去する
			if (collisionFlag == true) {
				natureObject = NatureObject.OBJ_SPACE;
			}

		}

		return;
	}
}