module stick;

import ball;
import DX_lib;

class Stick {

	int x; //スティックのx軸
	int y; //スティックのy軸
	int rightEnd;//スティックの右端
	const int stickHeight = 15; //スティックの高さ
	const int stickWidth = 75; //スティックの横幅

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

	int getRightEnd() {
		return this.x + stickWidth;
	}

	//ボールがスティックに衝突しているかをチェックする
	void ballCollisionCheck(ref Ball ball) {

		//ボールの座標がスティックの矩形に重なっていないかをチェックする

		//ボールのX座標がオブジェクトの矩形より大きく、ボールのX座標が矩形のX座標の幅よりも小さい場合、
		//または矩形のX座標がボールのX座標よりも大きく、かつ、矩形のX座標よりもボールのX座標がボールの横幅よりも大きい場合、
		//かつ、ボールのY座標が矩形のY座標よりも大きく、ボールのY座標が矩形のY座標の高さよりも大きい場合、
		//または矩形のY座標がボールのY座標よりも大きく、さらに矩形のY座標よりもボールのY座標がボールの縦幅よりも大きい場合、
		if (((ball.getX() > this.x) && (ball.getX() < (this.x + this.stickWidth)) ||
			 (this.x > ball.getX()) && (this.x < (ball.getX() + ball.getBallWidth()))) &&
			((ball.getY() > this.y) && (ball.getY() < (this.y + this.stickHeight)) ||
			 (this.y > ball.getY()) && (this.y < (ball.getY() + ball.getBallHeight()))))
		{
			//スティックの矩形と座標が重なっていたら、ボールを反射させる
			real angle = ball.getAngle();

			if (dx_GetRand(10) > 5) {
				angle -=  dx_GetRand(10);
			} else {
				angle +=  dx_GetRand(10);
			}

			ball.setAngle(-angle);
		}

		return;
	}
}