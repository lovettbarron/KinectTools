import org.openkinect.*;
import org.openkinect.processing.*;


class EzKinect {
  private PVector screen = new PVector( 640, 480, 0f );
  private PVector centroid, size;
  private int multi = 32;
  private int zmulti = 5;
  private int YDISPLACE = 520;
  private int thresh = 400;
  private int pointSize = 40;
  private Kinect kinect;

  private PImage depthImg, camImg, subtract;

  private int[] mask;
  private int[] depth;

  EzKinect( PApplet p) {
    //    screen = new PVector( p.width, p.height, 0f );
    kinect = new Kinect(p);
    kinect.start();
    kinect.enableDepth(true);
  }

  private void update( int _mode) { // 0 = both, 1 = depth, 2 = img
    if( _mode == 1 ) {
      try {
        depth = kinect.getRawDepth();

        if( mask != null ) {
          if(mask.length == depth.length) {
            for( int i = 0; i < depth.length; i++ ) {
              depth[i] =  mask[i] - depth[i];
            }
          }
        }
      } 
      catch ( NullPointerException e ) {
        println( "Kinect depth c'est ne pas ici" );
      }
    }
    else if ( _mode == 2 ) {
      try {
        depthImg = kinect.getDepthImage();
        camImg = kinect.getVideoImage();
      } 
      catch ( NullPointerException e ) {
        println( "Kinect cam c'est ne pas ici" );
      }
    }
  }

  public int[] getDepth() {
    return depth;
  }

  public PImage getMask() {
    return subtract;
  }

  public PImage getDepthImg() {
    return depthImg;
  }

  public PImage getImage() {
    return camImg;
  }

  public void setMask() {
    int[] mask = depth;
  }

  public void resetMask() {
    int[] mask = new int[0];
  }

  public void setThreshold( int _thresh ) {
    thresh = _thresh;
  }

  public void drawMap() {
  }

  public void setCentroid( PVector _centroid ) {
  }

  public PVector getCentroid() { 
    return centroid ;
  }

  public void quit() {
    kinect.quit();
  }
  ///////////////
  // Rendering //
  ///////////////

  public void render(PVector _centroid, PVector _size, int res ) {
    final PVector centroid = _centroid;  //Centroid of object, X + Z = centre, Y = base
    final PVector size = _size;
    stroke( 0 );
    strokeWeight( 4 );
    for( int i = 0; i < this.screen.x; i = i+res) {
      for( int j = 0; j < this.screen.y; j = j+res) {
        point( i-(centroid.x/2)*size.x, j-(centroid.y)*size.y, depth[int(i+j*this.screen.x)]*size.z );
      }
    }
  }

  public void renderMesh(PVector _centroid, PVector _size, int res ) {
    final PVector centroid = _centroid;  //Centroid of object, X + Z = centre, Y = base
    final PVector size = _size;
    stroke(10,10);
    fill( 128);

    fill(0, 51, 102);
    lightSpecular(255, 255, 255);
    directionalLight(204, 204, 204, 0, 0, -1);
    beginShape(QUADS);
    for( int i = 0; i < this.screen.x-res; i = i+res) {
      for( int j = 0; j < this.screen.y-res; j = j+res) {
  
//        println( depth[int(i+j*this.screen.x) ] );
        
        if( depth[int(i+j*this.screen.x)] > 1024 ) { 
          depth[int(i+j*this.screen.x)] /= 2;
        }
        if( depth[int((i+res)+j*this.screen.x)] > 1024 ) { 
          depth[int((i+res)+j*this.screen.x)] /= 2;
        }
        if( depth[int((i+res)+(j+res)*this.screen.x)] > 1024 ) { 
          depth[int((i+res)+(j+res)*this.screen.x)] /= 2;
        }
        if( depth[int(i+(j+res)*this.screen.x)] > 1024 ) { 
          depth[int(i+(j+res)*this.screen.x)] /= 2;
        }

        vertex( i-(centroid.x/2)*size.x, j-(centroid.y)*size.y, -depth[int(i+j*this.screen.x)]*size.z );
        vertex( i+res-(centroid.x/2)*size.x, j-(centroid.y)*size.y, -depth[int((i+res)+j*this.screen.x)]*size.z );
        vertex( i+res-(centroid.x/2)*size.x, j+res-(centroid.y)*size.y, -depth[int((i+res)+(j+res)*this.screen.x)]*size.z );
        vertex( i-(centroid.x/2)*size.x, j+res-(centroid.y)*size.y, -depth[int(i+(j+res)*this.screen.x)]*size.z );
      }
    }
    endShape();
  }
}

