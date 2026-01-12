package com.pixelwall.entity.pixel;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name ="pixel_metadata")
public class PixelMetadata {

    @EmbeddedId
    private PixelId pixelId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "x", referencedColumnName = "x"),
            @JoinColumn(name = "y", referencedColumnName = "y")
    })
    private Pixel pixel;

    @Column(name = "group_id", nullable = false)
    private Integer groupId;

    @Column(name = "label_hash", columnDefinition = "BINARY(32)")
    private byte[] labelHash;

    @Column(name = "link_hash", columnDefinition = "BINARY(32)")
    private byte[] linkHash;

    @Column(name = "color_r")
    private Short colorR;

    @Column(name = "color_g")
    private Short colorG;

    @Column(name = "color_b")
    private Short colorB;
}
