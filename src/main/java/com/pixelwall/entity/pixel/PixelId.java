package com.pixelwall.entity.pixel;

import jakarta.persistence.Embeddable;
import lombok.Data;

import java.io.Serializable;

@Data
@Embeddable
public class PixelId implements Serializable {

    private short x;
    private short y;

    public PixelId() {

    }

    public PixelId(short x, short y) {
        this.x = x;
        this.y = y;
    }
}