#include "../gui/gui.h"
#include "Vetor3D.h"

class Transform {
public:
  Vetor3D pos             = Vetor3D( 0.0, 0.0, 0.0 );
  Vetor3D rot             = Vetor3D( 0.0, 0.0, 0.0 );
  Vetor3D esc             = Vetor3D( 1.0, 1.0, 1.0 );
  bool    showLocalOrigin = true;

  void apply();
  void updateByMouse();
  void reset();
};
