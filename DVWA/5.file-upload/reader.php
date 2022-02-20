<?php
$exif = exif_read_data('demo.jpg', 0, true);
foreach ($exif as $key => $section) {
    foreach ($section as $name => $val) {
        if ($key == "COMMENT") {
            echo $val;
        }
    }
}
?>
