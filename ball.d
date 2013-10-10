module ball;

import std.math;

//ボールを管理する
class Ball {

	real x; //ボールの座標
	real y; //ボールの座標
	const int ballHeight = 15; //ボールの高さ
	const int ballWidth = 15; //ボールの横幅
	real speed; //ボールのスピード
	real angle; //ボールの角度

	this() {
		//ボールのスピード、角度を設定
		this.speed = 4;
	}

	real getX() {
		return this.x;
	}

	void setX(real x) {
		this.x = x;
	}

	real getY() {
		return this.y;
	}

	void setY(real y) {
		this.y = y;
	}

	int getBallHeight() {
		return this.ballHeight;
	}

	int getBallWidth() {
		return this.ballWidth;
	}

	real getSpeed() {
		return this.speed;
	}

	void setSpeed(real speed) {
		this.speed = speed;
	}

	real getAngle() {
		return this.angle;
	}

	void setAngle(real angle) {
		this.angle = angle;
	}

	//1フレーム毎のボールの移動
	void move() {

		//ラジアンを求める
		real radian = (angle / 360) * (PI * 2);

		real x = speed * cos(radian);
		real y = -(speed * sin(radian));

		this.x += x;
		this.y += y;

		return;
	}
}