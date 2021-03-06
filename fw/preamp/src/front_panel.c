/*
 * AmpliPi Home Audio
 * Copyright (C) 2021 MicroNova LLC
 *
 * Control for front panel LEDs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "front_panel.h"
#include <stdbool.h>
#include "ports.h"
#include "channel.h"

bool audio_power_on = false;

void delay(int a) {
	volatile int i,j;
	for (i=0 ; i < a ; i++){
		j++;
	}
	return;
}

void setAudioPower(bool on){
	audio_power_on = on;
	updateFrontPanel();
	if(on == 1)
	{
		delay(125000); // need time for volume IC to turn on
	}
}

void enableFrontPanel(){
	// init the i2c->gpio chip on the led board
	// this sets all IO pins to output
	// this ic controlls the 5V digital USB and 9V analog preamp power supplies
	// this ic also controls all the LEDs on the front of the box
	writeI2C2(front_panel_dir, ALL_OUTPUT);
}

void updateFrontPanel(){
	// bit 0: 5V usb power (inverted, off is '1')
	// bit 1: 9V analog power (not inverted, off is '0')
	// bits 2-7: channels 1 to 6 (in that corresponding order)
	uint8_t bits = 0;

	bits |= 0; // 5V usb power always on
	bits |= audio_power_on ? 2 : 0;

	uint8_t ch;
	for(ch = 0; ch < NUM_CHANNELS; ch++){
		bits |= (isOn(ch) ? 1 : 0) << (ch + 2);
	}

	writeI2C2(front_panel, bits);
}
