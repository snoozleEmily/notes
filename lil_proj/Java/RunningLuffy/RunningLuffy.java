package RunningLuffy;
import java.awt.*;
import java.awt.event.*;
import java.util.Random;
import javax.swing.*;

public class RunningLuffy {

    public static void main(String[] args) {
        JFrame frame = new JFrame("Running Luffy");
        frame.setSize(1200, 600);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLocationRelativeTo(null);

        Container contentPane = frame.getContentPane();
        contentPane.setLayout(null); // absolute positioning
        contentPane.setBackground(Color.RED);

        // Load GIF and get its actual size
        ImageIcon icon = new ImageIcon("MY_PATH/lil_proj/Java/luffy_run.gif");
        JLabel gifLabel = new JLabel(icon);

        int gifWidth = icon.getIconWidth();
        int gifHeight = icon.getIconHeight();
        gifLabel.setSize(gifWidth, gifHeight);

        contentPane.add(gifLabel);

        Random rand = new Random();

        // Change background color every second automatically
        new Timer(1000, e -> {
            Color randomColor = new Color(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256));
            contentPane.setBackground(randomColor);
        }).start();

        final int frameWidth = frame.getWidth();

        // Vertically center the GIF
        int startY = (frame.getHeight() - gifHeight) / 2 +100;

        // Start position just off screen to the left
        gifLabel.setLocation(-gifWidth, startY);

        // Animation timer to move the gif horizontally
        new Timer(16, new ActionListener() {
            int x = -gifWidth;
            final int speed = 5;

            @Override
            public void actionPerformed(ActionEvent e) {
                x += speed;
                if (x > frameWidth) {
                    x = -gifWidth;
                }
                gifLabel.setLocation(x, startY);
            }
        }).start();

        frame.setVisible(true);
    }
}
